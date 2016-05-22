class CreateFollows < ActiveRecord::Migration
  def change
    execute %{
CREATE TABLE IF NOT EXISTS `follows` (
  `user_id` int(11) NOT NULL,
  `friend_id` int(11) NOT NULL,
  PRIMARY KEY (`user_id`,`friend_id`),
  KEY `index_follows_user` (`user_id`),
  KEY `index_follows_friend` (`friend_id`),
  CONSTRAINT `fk_follows_friend` FOREIGN KEY (`friend_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_follows_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
}
  end
end
