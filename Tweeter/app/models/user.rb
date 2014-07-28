require_relative '../../lib/twitter_session'

class User < ActiveRecord::Base
  validates :screen_name, :presence => true
  validates :twitter_user_id, :presence => true, :uniqueness => true

  has_many(
  :statuses,
  :class_name => 'Status',
  :foreign_key => 'twitter_user_id',
  :primary_key => 'twitter_user_id'
  )

  def fetch_statuses!
    Status.fetch_by_twitter_user_id!(self.twitter_user_id)
  end

  def self.get_by_screen_name(screen_name)
    if TwitterSession.connected?
      self.fetch_by_screen_name!(screen_name)
    else
      self.where(screen_name: screen_name)
    end
  end

  def self.fetch_by_screen_name!(screen_name)
    json = TwitterSession.get("users/lookup",
                              { screen_name: screen_name })
    users = json.map { |user| self.parse_json(user) }

    old_ids = self.where(screen_name: screen_name).
                   pluck(:twitter_user_id)

    users = users.keep_if do |user|
      !old_ids.include?(user.twitter_user_id)
    end
    users.each { |status| status.save! }
    users
  end

  def self.parse_json(json)
    User.new(
    screen_name: json['screen_name'],
    twitter_user_id: json['id_str']
    )
  end
end