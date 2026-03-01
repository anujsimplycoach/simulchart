class DashboardsController < ApplicationController
  before_action :authenticate_user!

  CHART_COUNT = 300  # Change to 50 or 100 to stress test

  def index
    @dashboards = Dashboard.where(user_id: current_user.id.to_s)
  end

  def new
    @dashboard = Dashboard.new
  end

  def create
    @dashboard = Dashboard.new(dashboard_params)
    @dashboard.user_id = current_user.id.to_s
    if @dashboard.save
      redirect_to @dashboard, notice: 'Dashboard created!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @dashboard = Dashboard.find(params[:id])
    @charts    = Dashboard.chart_sources(count: CHART_COUNT)
  end

  private

  def dashboard_params
    params.require(:dashboard).permit(:name)
  end
end
