class User < ActiveRecord::Base

  validates :name, presence: true, uniqueness: true

  has_and_belongs_to_many :friends,
    join_table: :follows,
    class_name: 'User',
    foreign_key: :user_id,
    association_foreign_key: :friend_id

  # validate :cannot_follow_itself
  #
  # def cannot_follow_itself
  #   puts "VALIDATING #{friends.length}"
  #   self.friends.each do |friend|
  #     puts friend.id
  #     if friend.id == self.id
  #       errors.add(:friend_id, 'cannot follow itself')
  #     end
  #   end
  # end

  # FIXME: :friends visibility should be private to force
  # the use of :follow

  def follow(friend)
    return if friend.id.nil?
    return if friend.id == self.id
    return if friend.name == self.name
    self.friends.push(friend)
  end

end
