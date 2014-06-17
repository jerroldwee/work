class Attachment < ActiveRecord::Base

  has_attached_file :upload
  before_upload_post_process :no_processing
  before_create :add_guid

  def no_processing
    return false 
  end 

  def add_guid
    generate_token(:guid)
  end

  def generate_token(column)
    begin
      self[column] = secure_digest(Time.now, (1..10).map{ rand.to_s }) + 
                     secure_digest(Time.now, (1..20).map{ rand.to_s }) +
                     secure_digest(Time.now, (1..30).map{ rand.to_s })
    end while self.class.exists?(column => self[column])
  end

  def secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end

end
