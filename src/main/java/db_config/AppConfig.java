package db_config;

import java.io.InputStream;
import java.util.Properties;

/**
 * Central configuration loader.
 *
 * Values are read from <code>/config.properties</code> on the classpath
 * (WEB-INF/classes/config.properties at runtime). Any value can be overridden
 * by an environment variable whose name is the property key upper-cased with
 * dots replaced by underscores, e.g. {@code db.url} -> {@code DB_URL}.
 * This lets the same build run locally (file) and on a host (env vars).
 */
public final class AppConfig {

    private static final Properties PROPS = new Properties();

    static {
        try (InputStream in = AppConfig.class.getResourceAsStream("/config.properties")) {
            if (in != null) {
                PROPS.load(in);
            }
        } catch (Exception e) {
            throw new ExceptionInInitializerError(
                "Failed to load /config.properties: " + e.getMessage());
        }
    }

    private AppConfig() {
    }

    /** Returns the value for {@code key}, with an environment variable taking precedence. */
    public static String get(String key) {
        String envKey = key.toUpperCase().replace('.', '_');
        String env = System.getenv(envKey);
        if (env != null && !env.isBlank()) {
            return env;
        }
        return PROPS.getProperty(key);
    }

    /** Returns the value for {@code key}, or {@code defaultValue} if unset/blank. */
    public static String get(String key, String defaultValue) {
        String value = get(key);
        return (value != null && !value.isBlank()) ? value : defaultValue;
    }
}
