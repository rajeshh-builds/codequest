package com.codequest.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * High-Performance Thread-Safe Connection Pool & JDBC Manager for CodeQuest.
 * Features pre-warmed connection cache, transparent proxy reuse, statement caching,
 * and sub-millisecond connection borrowing for peak throughput.
 */
public class DBConnection {
    private static final String DEFAULT_URL = "jdbc:mysql://localhost:3306/codequest_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static final String DEFAULT_USER = "root";
    private static final String DEFAULT_PASSWORD = "";

    private static String url = DEFAULT_URL;
    private static String user = DEFAULT_USER;
    private static String password = DEFAULT_PASSWORD;

    private static final int INITIAL_POOL_SIZE = 5;
    private static final int MAX_POOL_SIZE = 25;
    private static final BlockingQueue<Connection> pool = new ArrayBlockingQueue<>(MAX_POOL_SIZE);
    private static final AtomicInteger createdCount = new AtomicInteger(0);
    private static volatile boolean initialized = false;

    static {
        loadConfig();
        initPool();
    }

    private static void loadConfig() {
        Properties props = new Properties();
        try (InputStream is = DBConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (is != null) {
                props.load(is);
            } else {
                File f = new File("db.properties");
                if (f.exists()) {
                    try (FileInputStream fis = new FileInputStream(f)) {
                        props.load(fis);
                    }
                }
            }
        } catch (Exception ignored) {}

        if (props.getProperty("db.url") != null) url = props.getProperty("db.url").trim();
        if (props.getProperty("db.user") != null) user = props.getProperty("db.user").trim();
        if (props.getProperty("db.password") != null) password = props.getProperty("db.password").trim();

        String envUrl = System.getenv("CQ_DB_URL");
        if (envUrl != null && !envUrl.trim().isEmpty()) {
            url = envUrl;
        }
        String envUser = System.getenv("CQ_DB_USER");
        if (envUser != null && !envUser.trim().isEmpty()) {
            user = envUser;
        }
        String envPass = System.getenv("CQ_DB_PASSWORD");
        if (envPass != null) {
            password = envPass;
        }

        // Optimize JDBC URL for high performance prepared statement caching
        if (!url.contains("cachePrepStmts")) {
            String sep = url.contains("?") ? "&" : "?";
            url = url + sep + "cachePrepStmts=true&prepStmtCacheSize=250&prepStmtCacheSqlLimit=2048&useServerPrepStmts=true";
        }
    }

    private static synchronized void initPool() {
        if (initialized) return;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            for (int i = 0; i < INITIAL_POOL_SIZE; i++) {
                Connection raw = createRawConnection();
                if (raw != null) {
                    pool.offer(raw);
                    createdCount.incrementAndGet();
                }
            }
            initialized = true;
        } catch (Exception e) {
            System.err.println("[CodeQuest Pool] Warning: Initializing pre-warmed pool: " + e.getMessage());
        }
    }

    private static Connection createRawConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL Driver not found", e);
        }
        return DriverManager.getConnection(url, user, password);
    }

    private DBConnection() {}

    public static Connection getConnection() throws SQLException, ClassNotFoundException {
        Connection physicalConn = null;
        while (physicalConn == null) {
            physicalConn = pool.poll();
            if (physicalConn != null) {
                try {
                    if (physicalConn.isClosed() || !physicalConn.isValid(1)) {
                        try { physicalConn.close(); } catch (Exception ignored) {}
                        createdCount.decrementAndGet();
                        physicalConn = null;
                    }
                } catch (Exception e) {
                    try { physicalConn.close(); } catch (Exception ignored) {}
                    createdCount.decrementAndGet();
                    physicalConn = null;
                }
            } else {
                if (createdCount.get() < MAX_POOL_SIZE) {
                    physicalConn = createRawConnection();
                    createdCount.incrementAndGet();
                } else {
                    try {
                        physicalConn = pool.poll(2, TimeUnit.SECONDS);
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                        throw new SQLException("Interrupted waiting for DB connection", e);
                    }
                    if (physicalConn == null) {
                        return createRawConnection();
                    }
                }
            }
        }

        final Connection target = physicalConn;
        return (Connection) Proxy.newProxyInstance(
            DBConnection.class.getClassLoader(),
            new Class<?>[]{Connection.class},
            new InvocationHandler() {
                private boolean closed = false;

                @Override
                public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                    String methodName = method.getName();
                    if ("close".equals(methodName)) {
                        if (!closed) {
                            closed = true;
                            releaseToPool(target);
                        }
                        return null;
                    } else if ("isClosed".equals(methodName)) {
                        return closed || target.isClosed();
                    } else if ("equals".equals(methodName)) {
                        return proxy == args[0];
                    } else if ("hashCode".equals(methodName)) {
                        return System.identityHashCode(proxy);
                    } else if ("toString".equals(methodName)) {
                        return "PooledConnection[" + target.toString() + "]";
                    }

                    if (closed) {
                        throw new SQLException("Connection has already been closed.");
                    }
                    return method.invoke(target, args);
                }
            }
        );
    }

    private static void releaseToPool(Connection raw) {
        if (raw == null) return;
        try {
            if (!raw.isClosed() && raw.isValid(1)) {
                if (!raw.getAutoCommit()) {
                    raw.setAutoCommit(true);
                }
                if (!pool.offer(raw)) {
                    raw.close();
                    createdCount.decrementAndGet();
                }
            } else {
                raw.close();
                createdCount.decrementAndGet();
            }
        } catch (Exception e) {
            try { raw.close(); } catch (Exception ignored) {}
            createdCount.decrementAndGet();
        }
    }

    public static void setCredentials(String newUrl, String newUser, String newPassword) {
        if (newUrl != null) url = newUrl;
        if (newUser != null) user = newUser;
        if (newPassword != null) password = newPassword;
        while (!pool.isEmpty()) {
            Connection c = pool.poll();
            if (c != null) {
                try { c.close(); } catch (Exception ignored) {}
            }
        }
        createdCount.set(0);
        initialized = false;
        initPool();
    }

    public static String getUrl() { return url; }
    public static String getUser() { return user; }

    public static void close(Connection conn, Statement stmt, ResultSet rs) {
        if (rs != null) {
            try { rs.close(); } catch (SQLException ignored) {}
        }
        if (stmt != null) {
            try { stmt.close(); } catch (SQLException ignored) {}
        }
        if (conn != null) {
            try { conn.close(); } catch (SQLException ignored) {}
        }
    }

    public static void close(Connection conn, Statement stmt) {
        close(conn, stmt, null);
    }
}
