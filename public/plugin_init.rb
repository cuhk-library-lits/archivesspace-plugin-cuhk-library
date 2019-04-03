require File.join(File.dirname(__FILE__), 'controllers/app_config_helper.rb')
AppConfigHelper.instance.reload

Plugins::extend_aspace_routes(File.join(File.dirname(__FILE__), 'routes.rb'))
Plugins::add_menu_item('/', 'brand.home', 0)

require File.join(File.dirname(__FILE__), 'controllers/concerns/manipulate_node.rb')

