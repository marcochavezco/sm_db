DROP DATABASE IF EXISTS x_db;

CREATE DATABASE x_db;

USE x_db;

DROP TABLE IF EXISTS users;

CREATE TABLE users (
	user_id INT NOT NULL AUTO_INCREMENT,
    user_handle VARCHAR(50) NOT NULL UNIQUE,
    email_address VARCHAR(50) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phonenumber CHAR(10) UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT (NOW()),
    PRIMARY KEY(user_id)
);

DROP TABLE IF EXISTS followers;

CREATE TABLE followers (
	follower_id INT NOT NULL,
    following_id INT NOT NULL,
    FOREIGN KEY(follower_id) REFERENCES users(user_id),
    FOREIGN KEY(following_id) REFERENCES users(user_id),
    PRIMARY KEY(follower_id, following_id)
);

ALTER TABLE followers
ADD CONSTRAINT check_follower_id
CHECK (follower_id <> following_id);


SELECT follower_id, following_id FROM followers;
SELECT following_id FROM followers WHERE follower_id = 1;
SELECT COUNT(follower_id) AS followers FROM followers WHERE following_id = 3;

-- Top 3 Most Followers
SELECT following_id, COUNT(follower_id) AS followers
FROM followers
GROUP BY following_id
ORDER BY followers DESC
LIMIT 3;

-- Top 3 Most Followers with user_handle
SELECT users.user_id, users.user_handle, users.first_name, following_id, COUNT(follower_id) AS followers
FROM followers
JOIN users ON users.user_id = followers.following_id
GROUP BY following_id
ORDER BY followers DESC
LIMIT 3;

DROP TABLE IF EXISTS posts;

CREATE TABLE posts (
	post_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    post_text VARCHAR(280) NOT NULL,
    num_likes INT DEFAULT 0,
    num_repost INT DEFAULT 0,
    num_comments INT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT (NOW()),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    PRIMARY KEY (post_id)
);

SELECT users.user_id, users.first_name, users.user_handle, post_text
FROM posts
JOIN users ON users.user_id = posts.user_id;

SELECT post_id, post_text, user_id
FROM posts
WHERE user_id IN (
	SELECT following_id
    FROM followers
    GROUP BY following_id
    HAVING COUNT(*) >= 2
);

SET SQL_SAFE_UPDATES = 0;

UPDATE posts SET num_comments = num_comments + 1 WHERE post_id = 1;

DROP TABLE IF EXISTS posts_likes;

CREATE TABLE posts_likes (
	user_id INT NOT NULL,
    post_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (post_id) REFERENCES posts(post_id),
    PRIMARY KEY (user_id, post_id)
);

-- Get the number of likes per post
SELECT posts.post_text, posts_likes.post_id, COUNT(*) AS likes
FROM posts_likes
JOIN posts ON posts.post_id = posts_likes.post_id
GROUP BY post_id;

/* TRIGGERS */ 
DROP TRIGGER IF EXISTS increase_like_count;

DELIMITER $$

CREATE TRIGGER increase_like_count
	AFTER INSERT ON posts_likes
    FOR EACH ROW
    BEGIN
		UPDATE posts SET num_likes = num_likes + 1
        WHERE post_id = NEW.post_id;
    END$$

DELIMITER ;