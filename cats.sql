CREATE TABLE cats (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  owner_id INTEGER,
  cat_house_id INTEGER,

  FOREIGN KEY(owner_id) REFERENCES human(id)
);

CREATE TABLE humans (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  house_id INTEGER,

  FOREIGN KEY(house_id) REFERENCES human(id)
);

CREATE TABLE houses (
  id INTEGER PRIMARY KEY,
  address VARCHAR(255) NOT NULL
);

CREATE TABLE cat_houses (
  id INTEGER PRIMARY KEY,
  color VARCHAR(255) NOT NULL
);

INSERT INTO
  houses (id, address)
VALUES
  (1, "26th and Guerrero"), (2, "Dolores and Market");

INSERT INTO
  humans (id, fname, lname, house_id)
VALUES
  (1, "Devon", "Watts", 1),
  (2, "Matt", "Rubens", 1),
  (3, "Ned", "Ruggeri", 2),
  (4, "Catless", "Human", NULL);

INSERT INTO
  cats (id, name, owner_id, cat_house_id)
VALUES
  (1, "Breakfast", 1, 1),
  (2, "Earl", 2, 2),
  (3, "Haskell", 3, 3),
  (4, "Markov", 3, 4),
  (5, "Stray Cat", NULL, 2);

INSERT INTO
  cat_houses (color)
VALUES
  ("blue"), ("black"), ("orange"), ("white");