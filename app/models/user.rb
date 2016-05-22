require 'set'

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

  def follow(*friends)
    friends.each do |friend|
    # fail 'friend id is nil' if friend.id == nil
      next if friend.id == self.id
      next if friend.name == self.name
      self.friends.push(friend)
    end
  end

  def suggest_friends
    candidates = Set.new()
    result = Set.new()
    self.friends.each do |friend|
      friend.friends.each do |candidate|
        next if friends.include? candidate
        if candidates.add?(candidate).nil?
          result.add(candidate)
        end
      end
    end
    result.to_a
  end

end
