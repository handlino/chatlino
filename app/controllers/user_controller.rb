class UserController < ApplicationController
  before_filter :require_login, :only=>[:invite]

  # display the summary of user rankings
  def index
  end

  def send_message
    @user = User.find(params[:id])
    @message.to_user = @user

  rescue
    flash[:error] = _"User not found"
    redirect_to :action => "index"
  end

  def history
    if params[:id] == "me"
      @user = @me
    else
      # this raises exception if not found, hence the handler below
      @user = User.find(params[:id])
    end
    @stories = TargetStory.find(:all, :conditions=>{:contributor_id=>@user.id}, :limit=>5, :order=>"created_at DESC")
  end

  def show
    if params[:id] == "me"
      @user = @me
    else
      # this raises exception if not found, hence the handler below
      @user = User.find(params[:id])
    end

    @email_confirmed = @user.email_confirmed

    @groups = @user.groups

    @is_my_contact = @user.has_contact?(@me)

    @msg = UserMessage.new
    @msg.box = 'inbox'
    @msg.from_user = @me
    @msg.to_user = @user
    @msg.subject = 'Default subject'

    @oa = UserStatistics.overall_accuracy_for_user(@user.id)
    @sa = UserStatistics.stock_accuracy_for_user(@user.id)
    @mat = UserStatistics.most_accurate_targets_for_user(@user.id)

  rescue
    redirect_to :controller=>'dashboard'
  end

  def invite
    if request.method == :get
      @invitation = Invitation.new
      @invitation.subject = @me.shortname + _(" invites you to YouHolder!")
      @invitation.message = _"Hi, I've joined in this Investment Circle service and I think it's quite nice. You may like it. A URL is attached at the end of this email."
    else
      @invitation = Invitation.new(params[:invitation])
      @invitation.user = @me

      # must validate first, otherwise errors array could be emptied (when the model is valid)
      @invitation.valid?

      # check if the user is already in our user db, or already invited
      if User.find(:first, :conditions=>{:email=>@invitation.email})
        @invitation.errors.add(:email, _("already belongs to a registered user"))
      elsif @me.invitations.find(:first, :conditions=>{:email=>@invitation.email})
        @invitation.errors.add(:email, _("is already being invited by you"))
      end

      if @invitation.errors.empty?
        @invitation.save
        AccountMailer.deliver_invitation(@invitation, request.host_with_port)
      end
    end

    @unaccepted = @me.pending_invitations
    @accepted = @me.accepted_invitations
  end
end
