{{ config
(
    alias = 'first_funded_by',
    schema = 'addresses_events',
    post_hook='{{ expose_spells(\'["arbitrum", "avalanche_c", "bnb", "ethereum", "fantom", "gnosis", "optimism", "polygon", "celo", "zora", "base", "scroll"]\',
                                    "sector",
                                    "addresses_events",
                                    \'["hildobby"]\') }}'
)
}}

{% set addresses_events_models = [
ref('addresses_events_arbitrum_first_funded_by')
, ref('addresses_events_avalanche_c_first_funded_by')
, ref('addresses_events_bnb_first_funded_by')
, ref('addresses_events_ethereum_first_funded_by')
, ref('addresses_events_fantom_first_funded_by')
, ref('addresses_events_gnosis_first_funded_by')
, ref('addresses_events_optimism_first_funded_by')
, ref('addresses_events_polygon_first_funded_by')
, ref('addresses_events_celo_first_funded_by')
, ref('addresses_events_zora_first_funded_by')
, ref('addresses_events_base_first_funded_by')
, ref('addresses_events_scroll_first_funded_by')
, ref('addresses_events_zkevm_first_funded_by')
, ref('addresses_events_linea_first_funded_by')
] %}

WITH joined_data AS (
    SELECT *
    FROM (
        {% for addresses_events_model in addresses_events_models %}
        SELECT blockchain
        , address
        , first_funded_by
        , first_funding_executed_by
        , block_time
        , block_number
        , tx_hash
        , tx_index
        FROM {{ addresses_events_model }}
        {% if not loop.last %}
        UNION ALL
        {% endif %}
        {% endfor %}
        )
    )

SELECT MIN_BY(blockchain, block_time) AS blockchain
, address
, MIN_BY(first_funded_by, block_time) AS first_funded_by
, array_distinct(array_agg(blockchain)) AS chains_funded_on
, MIN_BY(first_funding_executed_by, block_time) AS first_funding_executed_by
, MIN(block_time) AS block_time
, MIN(block_number) AS block_number
, MIN_BY(tx_hash, block_time) AS tx_hash
, MIN_BY(tx_index, block_time) AS tx_index
FROM joined_data
GROUP BY address