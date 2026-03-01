import { application } from "controllers/application"
import ChartController     from "controllers/chart_controller"
import DashboardController from "controllers/dashboard_controller"

application.register("chart",     ChartController)
application.register("dashboard", DashboardController)
