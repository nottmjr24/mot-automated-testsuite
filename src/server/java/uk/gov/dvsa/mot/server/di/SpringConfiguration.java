package uk.gov.dvsa.mot.server.di;

import org.apache.commons.dbcp.BasicDataSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.core.env.Environment;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.core.io.support.ResourcePatternResolver;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;
import uk.gov.dvsa.mot.server.data.DataDao;
import uk.gov.dvsa.mot.server.data.DatabaseDataProvider;
import uk.gov.dvsa.mot.server.data.QueryFileLoader;
import uk.gov.dvsa.mot.server.reporting.DataUsageReportGenerator;

import javax.sql.DataSource;

/**
 * Spring configuration class for the data server.
 */
@Configuration
@EnableTransactionManagement
@PropertySource("file:configuration/testsuite.properties")
public class SpringConfiguration {

    @Autowired
    Environment env;

    /**
     * Creates the database data source.
     * @return A connection pool based data source
     */
    @Bean
    public DataSource dataSource() {
        // use connection pool so that the connection gets re-used between scenarios in a feature
        BasicDataSource dataSource = new BasicDataSource();
        dataSource.setUrl(env.getRequiredProperty("jdbc.url")
                // useful mysql JDBC driver properties for debugging and logging
                // if switch to mariadb JDBC driver then change these
                + "?logSlowQueries=true&slowQueryThresholdMillis=500&dumpQueriesOnException=true"
                + "&gatherPerfMetrics=true&useUsageAdvisor=true&explainSlowQueries=true"
                + "&reportMetricsIntervalMillis=60000&logger=Slf4JLogger");
        dataSource.setUsername(env.getRequiredProperty("jdbc.username"));
        dataSource.setPassword(env.getRequiredProperty("jdbc.password"));
        dataSource.setDefaultAutoCommit(false);
        dataSource.setDefaultReadOnly(true);
        dataSource.setInitialSize(0);
        dataSource.setMaxActive(1); // up to 1 active connection in the pool, as scenarios are run in serial
        return dataSource;
    }

    @Bean
    public PlatformTransactionManager transactionManager(DataSource dataSource) {
        return new DataSourceTransactionManager(dataSource);
    }

    @Bean
    public JdbcTemplate jdbcTemplate(DataSource dataSource) {
        JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
        return jdbcTemplate;
    }

    @Bean
    public DatabaseDataProvider dataProvider(DataDao dataDao, QueryFileLoader queryFileLoader,
                                             DataUsageReportGenerator dataUsageReportGenerator) {
        return new DatabaseDataProvider(dataDao, queryFileLoader, dataUsageReportGenerator);
    }

    @Bean
    public ResourcePatternResolver classpathScanner() {
        return new PathMatchingResourcePatternResolver();
    }

    @Bean
    public QueryFileLoader queryFileLoader(ResourcePatternResolver classpathScanner) {
        return new QueryFileLoader(classpathScanner, env);
    }

    @Bean
    public DataDao dataDao(JdbcTemplate jdbcTemplate) {
        return new DataDao(jdbcTemplate);
    }

    @Bean
    public DataUsageReportGenerator dataUsageReportGenerator(Environment env) {
        return new DataUsageReportGenerator(env);
    }
}
