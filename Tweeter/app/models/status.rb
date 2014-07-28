require_relative '../../lib/twitter_session'

class Status < ActiveRecord::Base
  validates :text, :twitter_user_id, :presence => true
  validates :twitter_status_id, :presence => true, :uniqueness => true

  belongs_to(
  :user,
  :class_name => 'User',
  :foreign_key => 'twitter_user_id',
  :primary_key => 'twitter_user_id'
  )

  def self.get_by_twitter_user_id(twitter_user_id)
    if TwitterSession.connected?
      self.fetch_by_twitter_user_id!(twitter_user_id)
    else
      self.where(twitter_user_id: twitter_user_id)
    end
  end


  def self.fetch_by_twitter_user_id!(twitter_user_id)
    json = TwitterSession.get("statuses/user_timeline",
                              { user_id: twitter_user_id })
    statuses = json.map do |status|
      obj = self.parse_json(status)
    end

    old_ids = self.where(twitter_user_id: twitter_user_id).
                   pluck(:twitter_status_id)

    statuses = statuses.keep_if do |status|
      !old_ids.include?(status.twitter_status_id)
    end
    statuses.each { |status| status.save! }
    statuses
  end

  def self.parse_json(json)
    Status.new(
      text: json['text'],
      twitter_status_id: json['id_str'],
      twitter_user_id: json['user']['id_str'])
  end
end