class UsersController < ApplicationController
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_action :set_user, only: [:update]
  before_action :set_user_for_show, only: [:show]
  before_action :set_user_for_destroy, only: [:destroy]

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    if !(@user.comment.nil?)
      render json: {
        "message": "User details by user_id",
        "user": {
          "user_id": @user.user_id,
          "nickname": @user.nickname,
          "comment": @user.comment
        }
      }
    else
      render json: {
        "message": "User details by user_id",
        "user": {
          "user_id": @user.user_id,
          "nickname": @user.nickname,
        }
      }
    end
  end

  # POST /users
  def create
    if params = user_params
      @user = User.new(user_params)
      @user.nickname ||= @user.user_id
      if @user.save
        # render json: @user, status: :created, location: @user
        render status: 200, json: {
                        "message": "Account successfully created",
                        "user": {
                          "user_id": @user.user_id,
                          "nickname": @user.nickname
                        }
                      }
      else
        # render json: @user.errors, status: :unprocessable_entity
        render status: 400, json: {
                        "message": "Account creation failed",
                        "cause": @user.errors.messages
                      }
      end
    else
      render status: 400, json: {
                      "message": "Account creation failed",
                      "cause": "required user_id and password"
                      }
    end
  end

  # PATCH/PUT /users/1
  def update
    if params = update_params
      params[:comment] = params[:comment].gsub(/\r\n|\r|\n|\s|\t/, "") if !(params[:comment].nil?)
      params[:nickname] = @user.user_id if !(params[:nickname].nil?) && params[:nickname].gsub(/\r\n|\r|\n|\s|\t/, "").empty?
      if !(params[:user_id].nil?) || !(params[:password].nil?)
        render status: 400, json: {
                        "message": "User updation failed",
                        "cause": "not updatable user_id and password"
                      }
        return
      end
      if @user.update(params)
        render status: 200, json: {
          "message": "User successfully updated",
          "recipe": [
            {
              "nickname": @user.nickname,
              "comment": @user.comment
            }
          ]
        }
      else
        # render json: @user.errors, status: :unprocessable_entity
        render status: 400, json: {
                        "message": "User updation failed",
                        "cause": @user.errors.messages
                      }
      end
    else
      render status: 400, json: {
        "message": "User updation failed",
        "cause": "required nickname or comment"
      }
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    render status: 200, json: { "message": "Account and user successfully removed" }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find_by(user_id: params[:user_id])
      if @user
        http_basic_authenticate
      else
        render status: 404, json: { message: 'No User found' }
      end
    end

    def set_user_for_show
      if request.headers['HTTP_AUTHORIZATION'].nil?
        render_unauthorized
      else
        authenticate_or_request_with_http_basic do |username, password|
          if username.empty? && password.empty?
            render_unauthorized
          else
            @user = User.find_by(user_id: params[:user_id])
            user = User.find_by(user_id: username)
            if @user
              password == user.password ? true : render_unauthorized
            else
              render status: 404, json: { message: 'No User found' }
            end
          end
        end
      end
    end

    def set_user_for_destroy
      if request.headers['HTTP_AUTHORIZATION'].nil?
        render_unauthorized
      else
        authenticate_or_request_with_http_basic do |username, password|
          @user = User.find_by(user_id: username)
          if @user
            password == @user.password ? true : render_unauthorized
          else
            render_unauthorized
          end
        end
      end
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      begin
        params.require(:user).permit(:user_id, :password, :nickname, :comment)
      rescue
        return false
      end
    end

    def update_params
      begin
        params.require(:user).permit(:user_id, :password, :nickname, :comment)
      rescue
        return false
      end
    end

    def http_basic_authenticate
      if request.headers['HTTP_AUTHORIZATION'].nil?
        render_unauthorized
      else
        authenticate_or_request_with_http_basic do |username, password|
          if username == @user.user_id && password == @user.password
            true
          elsif username != @user.user_id
            render status: 403, json: { "message": "No Permission for Update" }

          else
            render_unauthorized
          end
        end
      end
    end


    def render_unauthorized
      render status: 401, json: { "message": "Authentication Faild" }
    end
end
