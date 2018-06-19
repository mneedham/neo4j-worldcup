CREATE CONSTRAINT ON (m:Match)
ASSERT m.id IS UNIQUE;

CREATE CONSTRAINT ON (w:WorldCup)
ASSERT w.year IS UNIQUE;

CREATE CONSTRAINT ON (s:Stadium)
ASSERT s.name IS UNIQUE;

CREATE CONSTRAINT ON (c:Country)
ASSERT c.id IS UNIQUE;

CREATE CONSTRAINT ON (p:Player)
ASSERT p.id IS UNIQUE;

CREATE CONSTRAINT ON (y:Year)
ASSERT y.year IS UNIQUE;

CREATE CONSTRAINT ON (s:Squad)
ASSERT s.name IS UNIQUE;

CREATE INDEX ON :Appearance(name);

CREATE INDEX ON :Player(name);


CALL apoc.schema.assert(
  {
    Player:['name'],
    Appearance:['name']
  },
  {
    Match:['id'],
    WorldCup:['year'],
    Stadium:['name'],
    Country:['id'],
    Player:['id'],
    Squad:['name']
  }
);