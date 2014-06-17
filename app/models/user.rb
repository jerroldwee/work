class User < ActiveRecord::Base

  has_many :credit_rewards
  has_many :user_fit_rooms
  has_many :prescriptions
  has_many :orders
  has_many :billing_addresses
  
  attr_accessor :password, :password_confirmation

  before_create :check_provider
  after_create :enable_api!
  after_create :add_initial_credit
  after_create :assign_token

  before_save :encrypt_password

  # need to implement validation with conditions
  validates_confirmation_of :password, :if => :should_validate_website_user?
  validates_presence_of :password, :on => :create, :if => :should_validate_website_user?
  validates_presence_of :email, :if => :should_validate_website_user?  
  validates_uniqueness_of :email, :if => :should_validate_website_user?
  validates_presence_of :username, :if => :should_validate_website_user?
  validates_uniqueness_of :username, :if => :should_validate_website_user?

  def should_validate_website_user?
    self.provider == "website"
  end

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|      
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.email = auth.info.email
      user.username = auth.info.nickname
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
    end
  end

  def self.authenticate(email, password)  
    user = where(:email => email).first
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)  
      user  
    else  
      nil  
    end  
  end

  def encrypt_password
    if provider == "website"
      if password.present?  
        self.password_salt = BCrypt::Engine.generate_salt  
        self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)  
      end
    end  
  end
  
  def self.authenticate(email, password)  
      user = where(:email => email).first
      if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)  
        user  
      else  
        nil  
      end  
  end

  def add_initial_credit
    total = 1
    CreditReward.create(:user_id => self.id, :description => "#{self.name} registered online", :reward_type => "Registration", :total => total)
    self.total_credit = total
    self.save
  end

  def enable_api!
      self.generate_api_key!
  end

  def disable_api!
    self.update_attribute(:api_key, "")
  end

  def api_is_enabled?
    !self.api_key.blank?
  end

  def update_total_credit
    self.total_credit = self.credit_rewards.sum("total")
  end

  def check_provider
    self.provider = "website" unless (self.provider == "facebook" || self.provider == "website")
  end

  def assign_token
    if self.provider == "website"
      generate_token(:token)
    save!
    end
  end

  # for forget password
  # def send_password_reset
  #   generate_token(:password_reset_token)
  #   self.password_reset_sent_at = Time.zone.now
  #   save!
  #   UserMailer.password_reset(self).deliver
  # end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end
  
  protected
  
    def secure_digest(*args)
      Digest::SHA1.hexdigest(args.flatten.join('--'))
    end

    def generate_api_key!
      self.update_attribute(:api_key, secure_digest(Time.now, (1..10).map{ rand.to_s })) unless api_is_enabled?
    end

end
