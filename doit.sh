#! /bin/bash

export WC_DB="/Users/markneedham/test-bench/databases/050/neo4j-enterprise-2.1.2"

${WC_DB}/bin/neo4j-shell --file data/import/clear.cyp
${WC_DB}/bin/neo4j-shell --file data/import/indexes.cyp
${WC_DB}/bin/neo4j-shell --file data/import/loadMatches.cyp
${WC_DB}/bin/neo4j-shell --file data/import/loadSquads.cyp
${WC_DB}/bin/neo4j-shell --file data/import/loadLineUps.cyp
${WC_DB}/bin/neo4j-shell --file data/import/loadEvents.cyp