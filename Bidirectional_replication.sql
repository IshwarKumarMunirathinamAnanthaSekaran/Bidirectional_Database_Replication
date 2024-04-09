-- Create schema_A
CREATE SCHEMA IF NOT EXISTS schema_A;

-- Create table_A in schema_A
CREATE TABLE IF NOT EXISTS schema_A.table_A (
    id INT AUTO_INCREMENT PRIMARY KEY,
    data VARCHAR(100),
    origin_schema VARCHAR(50) -- Column to track the origin of changes
);

-- Create schema_B
CREATE SCHEMA IF NOT EXISTS schema_B;

-- Create table_B in schema_B
CREATE TABLE IF NOT EXISTS schema_B.table_A (
    id INT AUTO_INCREMENT PRIMARY KEY,
    data VARCHAR(100),
    origin_schema VARCHAR(50) -- Column to track the origin of changes
);

USE schema_A;
-- Trigger for schema_A.table_A
DELIMITER //
CREATE TRIGGER replicate_to_schema_B_table_A
AFTER INSERT ON schema_A.table_A
FOR EACH ROW
BEGIN
    -- Check if the change originated from schema_B
    IF NEW.origin_schema <> 'schema_B' THEN
        -- Replicate the insert into schema_B.table_A
        INSERT INTO schema_B.table_A (data, origin_schema) VALUES (NEW.data, 'schema_A');
    END IF;
END;
//
DELIMITER ;


USE schema_B;

-- Trigger for schema_B.table_A
DELIMITER //
CREATE TRIGGER replicate_to_schema_A_table_A
AFTER INSERT ON schema_B.table_A
FOR EACH ROW
BEGIN
    -- Check if the change originated from schema_A
    IF NEW.origin_schema <> 'schema_A' THEN
        -- Replicate the insert into schema_A.table_A
        INSERT INTO schema_A.table_A (data, origin_schema) VALUES (NEW.data, 'schema_B');
    END IF;
END;
//
DELIMITER ;

USE schema_B;

INSERT INTO table_A (data,origin_schema)
VALUES ('Data 1','schema_B'),
       ('Data 2','schema_B'),
       ('Data 3','schema_B');
 select *from  schema_A.table_A;   
select *from  schema_B.table_A;

USE schema_A;

INSERT INTO table_A (data,origin_schema)
VALUES ('Data 4','schema_A');

 select *from  schema_A.table_A;   
select *from  schema_B.table_A;


USE schema_A;

-- Trigger for schema_A.table_A - UPDATE
DELIMITER //
CREATE TRIGGER update_replicate_to_schema_B_table_A
AFTER UPDATE ON schema_A.table_A
FOR EACH ROW
BEGIN
    -- Check if the change originated from schema_B
    IF NEW.origin_schema <> 'schema_B' THEN
        -- Replicate the update into schema_B.table_A
        UPDATE schema_B.table_A
        SET data = NEW.data, origin_schema = 'schema_A'
        WHERE id = OLD.id;
    END IF;
END;
//
DELIMITER ;

USE schema_B;

-- Trigger for schema_B.table_A - UPDATE
DELIMITER //
CREATE TRIGGER update_replicate_to_schema_A_table_A
AFTER UPDATE ON schema_B.table_A
FOR EACH ROW
BEGIN
    -- Check if the change originated from schema_A
    IF NEW.origin_schema <> 'schema_A' THEN
        -- Replicate the update into schema_A.table_A
        UPDATE schema_A.table_A
        SET data = NEW.data, origin_schema = 'schema_B'
        WHERE id = OLD.id;
    END IF;
END;
//
DELIMITER ;


USE schema_A;

-- Trigger for schema_A.table_A - DELETE
DELIMITER //
CREATE TRIGGER delete_replicate_to_schema_B_table_A
AFTER DELETE ON schema_A.table_A
FOR EACH ROW
BEGIN
    -- Check if the change originated from schema_B
    IF OLD.origin_schema <> 'schema_B' THEN
        -- Replicate the delete into schema_B.table_A
        DELETE FROM schema_B.table_A WHERE id = OLD.id;
    END IF;
END;
//
DELIMITER ;


USE schema_B;

-- Trigger for schema_B.table_A - DELETE
DELIMITER //
CREATE TRIGGER delete_replicate_to_schema_A_table_A
AFTER DELETE ON schema_B.table_A
FOR EACH ROW
BEGIN
    -- Check if the change originated from schema_A
    IF OLD.origin_schema <> 'schema_A' THEN
        -- Replicate the delete into schema_A.table_A
        DELETE FROM schema_A.table_A WHERE id = OLD.id;
    END IF;
END;
//
DELIMITER ;


 select *from  schema_A.table_A;   
select *from  schema_B.table_A;

-- Update a record in schema_A.table_A with origin_schema tracking
UPDATE schema_A.table_A
SET data = 'Updated Data 1', origin_schema = 'schema_A'
WHERE id = 1;

 select *from  schema_A.table_A;   
select *from  schema_B.table_A;

-- Delete a record from schema_B.table_A with origin_schema tracking
DELETE FROM schema_B.table_A
WHERE id = 4 AND origin_schema = 'schema_B';

select *from  schema_A.table_A;   
select *from  schema_B.table_A;

INSERT INTO schema_B.table_A (data,origin_schema)
VALUES ('Data 5','schema_B');