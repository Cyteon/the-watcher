CREATE TABLE Pings (
    id STRING NOT NULL,
    code INT NOT NULL,
    status STRING NOT NULL,
    time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
