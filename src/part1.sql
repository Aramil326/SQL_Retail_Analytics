DROP TABLE IF EXISTS personal_data CASCADE;
DROP TABLE IF EXISTS cards CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS checks CASCADE;
DROP TABLE IF EXISTS sku CASCADE;
DROP TABLE IF EXISTS stores_set CASCADE;
DROP TABLE IF EXISTS stores CASCADE;
DROP TABLE IF EXISTS groups_sku CASCADE;
DROP TABLE IF EXISTS Date_Of_Analysis_Formation CASCADE;
DROP TABLE IF EXISTS stores_set CASCADE;

CREATE TABLE IF NOT EXISTS personal_data
(
    Customer_ID            INT PRIMARY KEY,
    Customer_Name          TEXT,
    Customer_Surname       TEXT,
    Customer_Primary_Email TEXT,
    Customer_Primary_Phone TEXT,
    CONSTRAINT proper_name CHECK (Customer_Name ~* '^[A-Za-zА-Яа-я][a-zа-я\ _]+$'),
    CONSTRAINT proper_surname CHECK (Customer_Surname ~* '^[A-Za-zА-Яа-я][a-zа-я\ _]+$'),
    CONSTRAINT proper_email CHECK (Customer_Primary_Email ~* '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'),
    CONSTRAINT proper_phone CHECK (Customer_Primary_Phone ~ '^\+7\d{10}$')
);

CREATE TABLE IF NOT EXISTS cards
(
    Customer_Card_ID INT PRIMARY KEY,
    Customer_ID      INT NOT NULL REFERENCES personal_data (Customer_ID)
);

CREATE INDEX ON cards (customer_id);

CREATE TABLE IF NOT EXISTS transactions
(
    Transaction_ID       INT PRIMARY KEY,
    Customer_Card_ID     INT  NOT NULL REFERENCES cards (Customer_Card_ID),
    Transaction_Summ     REAL NOT NULL,
    Transaction_DateTime timestamp WITHOUT TIME ZONE,
    Transaction_Store_ID INT
);

CREATE TABLE groups_sku
(
    Group_ID   INT PRIMARY KEY,
    Group_Name TEXT,
    CONSTRAINT proper_name CHECK (Group_Name ~ '^[a-zA-Zа-яА-Я0-9\s\-\_\.,:;!@#$%^&*()+=?"''<>\/\\\[\]\{\}\|]{1,}$')
);

CREATE TABLE sku
(
    SKU_ID   INT PRIMARY KEY,
    SKU_Name TEXT,
    Group_ID INT NOT NULL REFERENCES groups_sku (Group_ID),
    CONSTRAINT proper_name CHECK (SKU_Name ~ '^[a-zA-Zа-яА-Я0-9\s\-\_\.,:;!@#$%^&*()+=?"''<>\/\\\[\]\{\}\|]{1,}$')
);

CREATE INDEX ON sku (Group_ID);

CREATE TABLE stores
(
    Transaction_Store_ID INT,
    SKU_ID               INT  NOT NULL REFERENCES sku (SKU_ID),
    SKU_Purchase_Price   REAL NOT NULL,
    SKU_Retail_Price     REAL NOT NULL,
    PRIMARY KEY (Transaction_Store_ID, SKU_ID)
);

CREATE TABLE IF NOT EXISTS checks
(
    Transaction_ID INT     NOT NULL REFERENCES transactions (Transaction_ID),
    SKU_ID         INT     NOT NULL REFERENCES sku (SKU_ID),
    SKU_Amount     NUMERIC NOT NULL,
    SKU_Summ       NUMERIC NOT NULL,
    SKU_Summ_Paid  NUMERIC NOT NULL,
    SKU_Discount   NUMERIC NOT NULL,
    PRIMARY KEY (Transaction_ID, SKU_ID)
);

CREATE TABLE Date_Of_Analysis_Formation
(
    Analysis_Formation TIMESTAMP WITHOUT TIME ZONE
);

SET datestyle = 'european';

-- IMPORT AND EXPORT PROCEDURES

CREATE OR REPLACE PROCEDURE importdb_mini(path text, delim "char")
    LANGUAGE plpgsql AS
$$
DECLARE
    tabs_list VARCHAR[] := ARRAY['Personal_Data',
        'Cards',
        'Transactions',
        'Groups_SKU',
        'SKU',
        'Stores',
        'Checks'
        ];
    tab_name VARCHAR;
BEGIN
    FOREACH tab_name IN ARRAY tabs_list
        LOOP
            EXECUTE 'COPY ' || tab_name ||' from '''|| path || '/datasets/' || tab_name || '_Mini.tsv'' WITH (FORMAT csv, DELIMITER'
                        ||  quote_literal(delim) || ')';
        END LOOP;
    EXECUTE 'COPY Date_Of_Analysis_Formation from '''|| path || '/datasets/Date_Of_Analysis_Formation.tsv'' WITH (FORMAT csv, DELIMITER'
                ||  quote_literal(delim) || ')';
END;
$$;



CREATE OR REPLACE PROCEDURE importdb_from_tsv(path text)
    LANGUAGE plpgsql AS
$$
DECLARE
    delim     "char"    = E'\t';
    tabs_list VARCHAR[] := ARRAY ['Personal_Data',
        'Cards',
        'Transactions',
        'Groups_SKU',
        'SKU',
        'Stores',
        'Checks',
        'Date_Of_Analysis_Formation'
        ];
    tab_name  VARCHAR;
BEGIN
    FOREACH tab_name IN ARRAY tabs_list
        LOOP
            EXECUTE 'COPY ' || tab_name || ' from ''' || path || '/' || tab_name ||
                    '.tsv'' WITH (FORMAT csv, DELIMITER'
                        || quote_literal(delim) || ')';
        END LOOP;
END;
$$;

CREATE OR REPLACE PROCEDURE importdb_from_csv(path text, delim "char")
    LANGUAGE plpgsql AS
$$
DECLARE
    tabs_list VARCHAR[] := ARRAY ['Personal_Data',
        'Cards',
        'Transactions',
        'Groups_SKU',
        'SKU',
        'Stores',
        'Checks',
        'Date_Of_Analysis_Formation'
        ];
    tab_name  VARCHAR;
BEGIN
    FOREACH tab_name IN ARRAY tabs_list
        LOOP
            EXECUTE 'COPY ' || tab_name || ' from ''' || path || '/' || tab_name ||
                    '.csv'' WITH (FORMAT csv, DELIMITER'
                        || quote_literal(delim) || ')';
        END LOOP;
END;
$$;

CREATE OR REPLACE PROCEDURE exportdb_to_csv(path text, delim "char")
    LANGUAGE plpgsql AS
$$
DECLARE
    tabs_list VARCHAR[] := ARRAY ['Personal_Data',
        'Cards',
        'Transactions',
        'Groups_SKU',
        'SKU',
        'Stores',
        'Checks',
        'Date_Of_Analysis_Formation'
        ];
    tab_name  VARCHAR;
BEGIN
    FOREACH tab_name IN ARRAY tabs_list
        LOOP
            EXECUTE 'COPY ' || tab_name || ' to ''' || path || '/' || tab_name || '.csv'' WITH (FORMAT csv, DELIMITER'
                        || quote_literal(delim) || ')';
        END LOOP;
END;
$$;

CREATE OR REPLACE PROCEDURE exportdb_to_tsv(path text)
    LANGUAGE plpgsql AS
$$
DECLARE
    delim     "char"    = E'\t';
    tabs_list VARCHAR[] := ARRAY ['Personal_Data',
        'Cards',
        'Transactions',
        'Groups_SKU',
        'SKU',
        'Stores',
        'Checks',
        'Date_Of_Analysis_Formation'
        ];
    tab_name  VARCHAR;
BEGIN
    FOREACH tab_name IN ARRAY tabs_list
        LOOP
            EXECUTE 'COPY ' || tab_name || ' to ''' || path || '/' || tab_name || '.tsv'' WITH (FORMAT csv, DELIMITER'
                        || quote_literal(delim) || ')';
        END LOOP;
END;
$$;

--Mini dataset
CALL importdb_mini('/Users/gwynesse/projects/SQL3_RetailAnalitycs_v1.0-2', E'\t');

--Maxi dataset
-- CALL importdb_from_tsv('/Users/gwynesse/projects/SQL3_RetailAnalitycs_v1.0-1/datasets');

-- Other import, export
-- CALL exportdb_to_csv('/tmp', '-');
-- CALL importdb_from_csv('/tmp', '-');
-- CALL exportdb_to_tsv('/tmp');





