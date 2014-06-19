#! /bin/bash
set -e

if [[ -z "$WC_DB" ]]; then
	echo "Make sure you set \$WC_DB before running this script"
	echo "e.g. export WC_DB=\"/path/to/neo4j-enterprise-2.1.2\""
	exit 1
fi

echo "starting up Neo4j instance at ${WC_DB}"
${WC_DB}/bin/neo4j status
if [ $? -ne 0 ]; then
	echo "Neo4j not started. Run ${WC_DB}/bin/neo4j start before running this script"	
fi


${WC_DB}/bin/neo4j-shell --file data/import/clear.cyp
${WC_DB}/bin/neo4j-shell --file data/import/indexes.cyp
${WC_DB}/bin/neo4j-shell --file data/import/loadMatches.cyp
${WC_DB}/bin/neo4j-shell --file data/import/connectAdjacentWorldCups.cyp
${WC_DB}/bin/neo4j-shell --file data/import/loadSquads.cyp
${WC_DB}/bin/neo4j-shell --file data/import/loadLineUps.cyp
${WC_DB}/bin/neo4j-shell --file data/import/loadEvents.cyp