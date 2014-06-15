#! /bin/bash

if [[ -z "$WC_DB" ]]; then
	echo "Make sure you set \$WC_DB before running this script"
	echo "e.g.export WC_DB="/Users/markneedham/test-bench/databases/050/neo4j-enterprise-2.1.2""
	exit 1
fi

${WC_DB}/bin/neo4j-shell --file data/import/clear.cyp
${WC_DB}/bin/neo4j-shell --file data/import/indexes.cyp
${WC_DB}/bin/neo4j-shell --file data/import/loadMatches.cyp
${WC_DB}/bin/neo4j-shell --file data/import/loadSquads.cyp
${WC_DB}/bin/neo4j-shell --file data/import/loadLineUps.cyp
${WC_DB}/bin/neo4j-shell --file data/import/loadEvents.cyp