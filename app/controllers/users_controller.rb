class UsersController < ApplicationController
  before_action :find_user, only: :show
  # before_action :product_ids_from_user, only: [:index, :show]

  def find_user
    @user = User.find(session[:user_id])
  end

  def show
    sorted_orders

    @total_revenue = @order_items.nil? ? 0 : revenue(@order_items)
    @paid_revenue = User.orders_items_from_order(@paid_orders, @user).nil? ? 0 : revenue(User.orders_items_from_order(@paid_orders, @user))
    @completed_revenue = User.orders_items_from_order(@completed_orders, @user).nil? ? 0 : revenue(User.orders_items_from_order(@completed_orders, @user))
  end

  def sorted_orders
    # associations
    product_ids = User.product_ids_from_user(@user)
    @order_items = User.order_items_from_products(product_ids).nil? ? [] : User.order_items_from_products(product_ids)
    @orders = User.orders_from_order_items(@order_items)

    # needed for a count of orders based on status
    # an array of Order objects
    @pending_orders = Order.by_status(@orders, "pending")
    @paid_orders = Order.by_status(@orders, "paid")
    @completed_orders = Order.by_status(@orders, "complete")
    @cancelled_orders = Order.by_status(@orders, "cancelled")

    order_items_except_cancelled = @order_items.reject { |item| item.order.status == 'cancelled' }
    @total_revenue = revenue(order_items_except_cancelled)
    @paid_revenue = User.orders_items_from_order(@paid_orders, @user).nil? ? 0 : revenue(User.orders_items_from_order(@paid_orders, @user))
    @completed_revenue = User.orders_items_from_order(@completed_orders, @user).nil? ? 0 : revenue(User.orders_items_from_order(@completed_orders, @user))

    @products = Product.top_5(@user.products.to_a)
    @latest_orders = Order.latest_5(@orders)
  end

  def new
    if session[:user_id].nil?
      @user = User.new
      render :new
    else
      flash[:alert] = "You can't make a new account while you're currently logged in."
      redirect_to root_path
    end
  end

  def create # create a new logged in user
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id # creates a session - they are logged in
      redirect_to user_path(@user)
    else
      render :new
    end
  end

  def list_of_orders # returns array of order assoc w/ order items of user
    sorted_orders
    @order_statuses = [@pending_orders, @paid_orders, @completed_orders, @caneled_orders]
    # @order_statuses.each do |order_status|
      # if order_status.nil? || order_status.empty?
        # order_status = nil
      # else
        # revenue_by_order(order_status)
      # end
    # end
  end

  # def revenue_by_order(order_status)
  #  order_status.each do |order|
    #  @item_qty = 0
    #  @revenue_by_order = 0
    #  @total_revenue_by_status = 0
    #  items = @order_items.find_all {|order_item| order_item.order_id == order.id }
    #  items.each do |item|
      #  @item_qty += item.quantity
      #  @price_of_item = Product.find(item.product_id).price
      #  @revenue_by_item = @price_of_item * item.quantity
      #  @revenue_by_order += @revenue_by_item
      #  end
    #  @total_revenue_by_status += @revenue_by_order
    # end
  # end


  private

  def self.model
    User
  end # USED FOR RSPEC SHARED EXAMPLES

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end

  def revenue(order_items)
    return 0 if order_items.nil?
    order_items.reduce(0) { |sum, n| sum + (n.product.price * n.quantity)}
  end
end
