class AccountController < ApplicationController
  before_filter :require_login, :only=>[:settings, :confirm]

  def index
    redirect_to :controller=>'chatroom'
  end

  def ajax_login
    if request.method == :post
      success = login_authenticate(params[:user][:email], params[:user][:password])
    else
      success = false
    end

    cn = params[:id]

    render :update do |page|
      if success
        page << "YouHolder.Util.accountDialog.loginSuccess('#{cn}');";
      else
        page << "YouHolder.Util.accountDialog.loginFailure();"
      end
    end
  end

  # TO DO: Replace the error message with localized strings
  def login
    if !@me.is_guest?
      redirect_back_after_login_with_default :controller=>'chatroom'
    end
    if request.method == :post
      if login_authenticate(params[:user][:email], params[:user][:password])
        if params[:user_save_cookie]
          @session_only = false
        else
          @session_only = true
        end

        if params[:ajax]
          render :update do |page|
            page.redirect_to :controller=>'chatroom'
          end
        else
          redirect_back_after_login_with_default :controller=>'chatroom'
        end
      else
        @user = User.new
        @user.email = params[:user][:email]
        cookies.delete(:last_email)

        @error_msg  = "Login unsuccessful"

        if params[:ajax]
          render :text => {"error_msg" => "Login unsuccessful"}.to_json
        end
      end
    else
      @user = User.new
      if cookies[:last_email]
        @user.email = cookies[:last_email]
      end
    end
  end

  def signup
    if !@me.is_guest?
      redirect_back_after_login_with_default :controller=>'chatroom'
    end
    code = params[:id] || params[:invitation_code]

    inv = Invitation.fetch_invitation(params[:id])
    logger.error "inv = #{inv}"

    if inv && inv.accepted
      inv = nil
    end

    logger.error "inv = #{inv}"

    case request.method
      when :post
        @user = User.new(params[:user])

        if @user.save
          # create the confirm code
          cf = Confirmation.new
          cf.code = Confirmation.generate_confirm_code(@user.id)
          cf.user_id = @user.id
          cf.save

          email = AccountMailer.deliver_welcome([@user.email], cf.code, request.host_with_port)

          # create welcome message
          UserMessage.create(:from_user=>User.admin, :to_user=>@user, :subject=>_("Welcome to YouHolder!"), :body=>_("Welcome to YouHolder, you can do lots of things here."))

          # if there's an invitation
          # TO DO: check invitation code validity
          if inv
            inv.accepted_at = Time.now
            inv.accepted = true
            inv.registered_user_id = @user.id
            inv.save
            UserMessage.create(:from_user=>User.admin, :to_user=>inv.user, :subject=>_("Your invitation has been accepted"), :body=>(_("Your invitation sent to %s has been accepted. And %s has been added to your contact list") % [inv.email, @user.shortname]))

            # add contact bonds for both side
            ContactBond.create(:user => inv.user, :contact => @user)
            ContactBond.create(:user => @user, :contact => inv.user)

            # tells the invited user the person who invited him/her has been added to his/her contact list
            UserMessage.create(:from_user=>User.admin, :to_user=>@user, :subject=>_("Your first contact has been added!"), :body=>(_("%s, the person who has invited you to join YouHolder, has been added to your contact list.") % inv.user.shortname))
          end

          # put this user in
          login_authenticate(params[:user][:email], params[:user][:password])
          redirect_back_after_login_with_default :controller=>'chatroom'
        end
      when :get
        @user = User.new
        if inv
          @user.email = inv.email
          @invitation_code = inv.invitation_code
        end
    end
  end

  def logout
    cookies.delete :user
    @me = User.new
    redirect_to :controller=>'chatroom'
  end

  # change user settings
  def settings
    case request.method
      when :post
        logger.info @me.to_yaml

        @user = User.new(@me.attributes)

        # this needs done by us
        @user.id = @me.id

        # what really gets changed -- not much for the time being
        @user.nickname = params[:user][:nickname]
        @user.user_name = params[:user][:user_name]
        @user.photo_path = params[:user][:photo_path]

        logger.info @user.to_yaml

        @user.validate

        # if the user wants to change the password
        if !params[:old_password].blank?
          if params[:user][:password].blank?
            @user.errors.add(:password, 'cannot be blank')
          end

          if !login_authenticate(@user.email, params[:old_password])
            @user.errors.add_to_base('Old password does not match')
          end

          if params[:user][:password] != params[:user][:password_confirmation]
            @user.errors.add(:password, 'does not match with the confirmation')
          end

          if @user.errors.empty?
            @user.change_password(params[:user][:password])
          end
        end

        if !params[:user][:password].blank? && params[:old_password].blank?
          @user.errors.add_to_base('Must give the old password in order to change it')
        end

        if @user.errors.empty? && @user.update
          @error_msg = 'Settings updated'
        end

        @me = @user
      when :get
        @user = User.new(@me.attributes)
        logger.info @user.attributes.to_yaml
    end

    # clear up password field so it's not showing up in the view
    @user.password = nil
  end

  def confirm
    cf = Confirmation.find(:first, :conditions=>{:code => params[:id]})

    if !cf || cf.user_id != @me.id || @me.email_confirmed
      @success = false
    else
      @me.email_confirmed = true
      @me.update
      @success = true
    end
  end

  def requires_email_confirmation
  end

  protected
    # used by Account#login
    def login_authenticate(login_name, password)
      if u = User.authenticate(login_name, password)
        @me = u
      end
    end

    # used by the Account controller
    def redirect_back_after_login_with_default(default)
      if session[:redirect_to_after_login].blank?
        redirect_to default
      else
        redirect_to_url session[:redirect_to_after_login]
        session[:redirect_to_after_login] = nil
      end
    end
end
