#!/bin/bash

NETWORKS=("holesky" "sepolia")
DEPLOYMENTS="./deployments.json"
TOKENS=("solvBTC" "pumpBTC")

# Initialize deployments file if it doesn't exist
if [ ! -f "$DEPLOYMENTS" ]; then
    echo "{}" >"$DEPLOYMENTS"
fi

# Function to deploy a token on a specific network
deploy_token() {
    local NETWORK=$1
    local TOKEN_NAME=$2
    local SYMBOL=$3
    local TEMP_PARAMS="./${NETWORK}_params.json"

    echo "{\"name\": \"$TOKEN_NAME\", \"symbol\": \"$SYMBOL\"}" >"$TEMP_PARAMS"

    OUTPUT=$(NETWORK=$NETWORK npx hardhat run scripts/deployMockToken.ts --network "$NETWORK" 2>&1)

    if echo "$OUTPUT" | grep -q "MockERC20 deployed to:"; then
        ADDRESS=$(echo "$OUTPUT" | grep "MockERC20 deployed to:" | awk '{print $NF}')
        echo "Deployed $TOKEN_NAME to $NETWORK at address: $ADDRESS"

        # Update the deployments.json with the new address
        jq ". + {\"$NETWORK\": (.\"$NETWORK\" // {} | . + {\"$TOKEN_NAME\": \"$ADDRESS\"})}" "$DEPLOYMENTS" >tmp.json && mv tmp.json "$DEPLOYMENTS"
    else
        echo "Failed to deploy $TOKEN_NAME to $NETWORK."
        echo "$OUTPUT"
        exit 1
    fi

    rm "$TEMP_PARAMS"
}

# Function to get all token addresses for a specific network
get_token_addresses() {
    local NETWORK=$1
    jq -r ".[\"$NETWORK\"] | to_entries | map(.value) | join(\",\")" "$DEPLOYMENTS"
}

# Deploy each token on each network
# Uncomment to deploy tokens if needed

for NETWORK in "${NETWORKS[@]}"; do
    for TOKEN_NAME in "${TOKENS[@]}"; do
        SYMBOL="m${NETWORK}_${TOKEN_NAME}"
        deploy_token "$NETWORK" "$TOKEN_NAME" "$SYMBOL"
    done
done

# Function to deploy CrossChainVault on multiple networks
deploy_cross_chain_vault() {
    for NETWORK in "${NETWORKS[@]}"; do
        echo "Deploying CrossChainVault to $NETWORK..."

        OUTPUT=$(NETWORK=$NETWORK npx hardhat run scripts/deployCrossChainVault.ts --network "$NETWORK" 2>&1)

        if echo "$OUTPUT" | grep -q "CrossChainVault deployed to:"; then
            ADDRESS=$(echo "$OUTPUT" | grep "CrossChainVault deployed to:" | awk '{print $NF}')
            echo "Deployed CrossChainVault to $NETWORK at address: $ADDRESS"

            # Update deployments.json with the CrossChainVault address
            jq ". + {\"$NETWORK\": (.\"$NETWORK\" // {} | . + {\"CrossChainVault\": \"$ADDRESS\"})}" "$DEPLOYMENTS" >tmp.json && mv tmp.json "$DEPLOYMENTS"
        else
            echo "Failed to deploy CrossChainVault on $NETWORK."
            echo "$OUTPUT"
            exit 1
        fi
    done
}

# deploy_cross_chain_vault

# Deploy ABTCVault on Akkad network
echo "Deploying ABTCVault on Akkad network..."

OUTPUT=$(NETWORK=akkad npx hardhat run scripts/deployABTCVault.ts --network akkad 2>&1)

if echo "$OUTPUT" | grep -q "ABTCVault deployed to:"; then
    ADDRESS=$(echo "$OUTPUT" | grep "ABTCVault deployed to:" | awk '{print $NF}')
    echo "Deployed ABTCVault to Akkad at address: $ADDRESS"

    # Add ABTCVault address to deployments.json under the key "akkad-ABTVault"
    jq ". += {\"akkad-ABTCVault\": \"$ADDRESS\"}" "$DEPLOYMENTS" >tmp.json && mv tmp.json "$DEPLOYMENTS"
else
    echo "Failed to deploy ABTCVault on Akkad."
    echo "$OUTPUT"
    exit 1
fi

echo "All deployments completed."
