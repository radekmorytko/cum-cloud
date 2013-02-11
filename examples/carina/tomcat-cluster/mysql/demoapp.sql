CREATE DATABASE IF NOT EXISTS demoapp;

USE demoapp;

CREATE TABLE IF NOT EXISTS example (
         id INT,
         data VARCHAR(100)
       );

INSERT INTO example VALUES (10, 'test');
INSERT INTO example VALUES (20, 'example value');

COMMIT;

