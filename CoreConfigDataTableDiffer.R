library(DBI)
library(RODBC)
library(RMySQL)
library(compareDF)

# Setup connections
table1.connection <- odbcConnect("SOURCE")
table1.prefix <- ""
table2.connection <- odbcConnect("DESTINATION")
table2.prefix <- ""

print('Welcome to the MagentoTableDiffer!')
print('')

tablename <- 'core_config_data'
print(paste("Comparing table '", tablename, "'...", sep=""))

exclude <- c(
             "amasty_base/system_value/last_update",
             "amasty_base/system_value/remove_date",
             "amasty_checkout/geolocation/google_api_key",

             "analytics/general/token",

             "carriers/fedex/account",
             "carriers/fedex/key",
             "carriers/fedex/meter_number",
             "carriers/fedex/password",

             "carriers/tablerate/import",

             "dev/debug/template_hints_blocks",
             "dev/debug/template_hints_storefront",
             "dev/grid/async_indexing",
             "dev/quickdevbar/appearance",
             "dev/quickdevbar/area",
             "dev/quickdevbar/enable",

             "google/analytics/account",
             
             "magebird/notifications/last_check",
             "magebird_popup/general/extension_key",
             "magebird_popup/general/licence_key",
             "magebird_popup/general/trial_start",
             "magebird_popup/services/mailchimp_key",

             "payment/amazon_payments/simplepath/privatekey",
             "payment/amazon_payments/simplepath/publickey",
             "payment/bambora/api_access_passcode",
             "payment/bambora/merchant_id",
             "payment/rootways_authorizecim_basic/api_client_key",
             "payment/rootways_authorizecim_basic/api_login_id",
             "payment/rootways_authorizecim_basic/api_trans_key",
             "payment/rootways_authorizecim_basic/environment",
             "payment/rootways_authorizecim_basic/gateway_url",
             "payment/rootways_authorizecim_option/v3_secret_key",
             "payment/rootways_authorizecim_option/v3_site_key",

             "rootways_authorizecim/general/lcstatus",
             "rootways_authorizecim/general/licencekey",

             "smtp/configuration_option/authentication",
             "smtp/configuration_option/host",
             "smtp/configuration_option/password",
             "smtp/configuration_option/port",
             "smtp/configuration_option/protocol",
             "smtp/configuration_option/return_path_email",
             "smtp/configuration_option/test_email/to",
             "smtp/configuration_option/username",
             
             "system/full_page_cache/caching_application",
             "system/full_page_cache/varnish/access_list",
             "system/full_page_cache/varnish/backend_host",
             "system/smtp/host",
             "system/smtp/port",
             
             "web/cookie/cookie_domain",
             "web/secure/base_link_url",
             "web/secure/base_url",
             "web/secure/base_media_url",
             "web/secure/base_static_url",
             "web/unsecure/base_link_url",
             "web/unsecure/base_url",
             "web/unsecure/base_media_url",
             "web/unsecure/base_static_url"
)

# Wrap with single quotes and collapse
exclude.clause <- paste("'", exclude, "'", sep="", collapse=',')

# Build table names.
table1.tablename <- paste(table1.prefix, tablename, sep="")
table2.tablename <- paste(table2.prefix, tablename, sep="")

# Build queries.
table1.query <- paste("SELECT scope, scope_id, path, value FROM", table1.tablename, "WHERE `path` NOT IN (", exclude.clause, ") ORDER BY path, scope")
table2.query <- paste("SELECT scope, scope_id, path, value FROM", table2.tablename, "WHERE `path` NOT IN (", exclude.clause, ") ORDER BY path, scope")

# Grab data
table1.data <- sqlQuery(table1.connection, table1.query)
table2.data <- sqlQuery(table2.connection, table2.query)

ctable <- compare_df(table2.data, table1.data, c("path", "scope"))

# Clean up
close(table1.connection)
close(table2.connection)

View(ctable["comparison_df"])