CREATE ROLE Administrator;

GRANT ALL ON personal_data, cards, transactions, groups_sku, sku, stores, checks, Date_Of_Analysis_Formation TO Administrator;

CREATE ROLE Visitor;

GRANT SELECT ON personal_data, cards, transactions, groups_sku, sku, stores, checks, Date_Of_Analysis_Formation TO Visitor;

-- REVOKE ALL ON personal_data, cards, transactions, groups_sku, sku, stores, checks, Date_Of_Analysis_Formation FROM Administrator;
-- REVOKE SELECT ON personal_data, cards, transactions, groups_sku, sku, stores, checks, Date_Of_Analysis_Formation FROM Visitor;
