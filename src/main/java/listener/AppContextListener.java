package listener;

import com.mysql.cj.jdbc.AbandonedConnectionCleanupThread;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

@WebListener
public class AppContextListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("LCPS Application Started");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        try {
            // Stop MySQL's abandoned-connection cleanup thread so the
            // webapp unloads cleanly without leaking it across redeploys.
            AbandonedConnectionCleanupThread.checkedShutdown();
            System.out.println("MySQL Cleanup Thread Stopped");
        } catch (Exception e) {
            throw new RuntimeException("Failed to stop MySQL cleanup thread", e);
        }
    }
}
