# This is not a model per se, but a generic object that contains the
# logic required to update a user's friends making calls to the Twitter REST API
# Maybe we should call it a service?
class UpdateQueue

  # Return the users that needs an update
  def self.get_first_users(threshold, limit = 10)
    date_min = Time.now.to_i - threshold
    users = User.all(:u)
      .where("u.level < {level_max}")
      .where("u.last_update < {date_min}")
      .params(level_max: User::LEVEL_OTHER, date_min: date_min)
      .limit(limit)
      .order(:last_update)
  end

end
