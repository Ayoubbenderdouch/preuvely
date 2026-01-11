<?php

use Knuckles\Scribe\Extracting\Strategies;
use Knuckles\Scribe\Config\Defaults;
use Knuckles\Scribe\Config\AuthIn;
use function Knuckles\Scribe\Config\{removeStrategies, configureStrategy};

return [
    'title' => 'Preuvely API Documentation',

    'description' => 'API for Preuvely - Trusted Store Reviews Platform for Algeria',

    'intro_text' => <<<INTRO
        Welcome to the Preuvely API documentation!

        Preuvely is a trust/review directory for online stores in Algeria. Users can search stores, view ratings, and leave reviews with star ratings and comments.

        ## Authentication
        This API uses Laravel Sanctum for authentication. To authenticate:
        1. Register or login to get a bearer token
        2. Include the token in the Authorization header: `Bearer {YOUR_TOKEN}`

        ## High-Risk Categories
        Some categories (digital services, USDT, gift cards) are considered high-risk. Reviews for stores in these categories require proof uploads and admin approval before becoming visible.

        <aside>As you scroll, you'll see code examples for working with the API in the dark area to the right (or as part of the content on mobile).</aside>
    INTRO,

    'base_url' => env('APP_URL', 'http://localhost:8000'),

    'routes' => [
        [
            'match' => [
                'prefixes' => ['api/v1/*'],
                'domains' => ['*'],
            ],
            'include' => [],
            'exclude' => [],
        ],
    ],

    'type' => 'static',

    'theme' => 'default',

    'static' => [
        'output_path' => 'public/docs',
    ],

    'laravel' => [
        'add_routes' => true,
        'docs_url' => '/docs',
        'assets_directory' => null,
        'middleware' => [],
    ],

    'external' => [
        'html_attributes' => []
    ],

    'try_it_out' => [
        'enabled' => true,
        'base_url' => null,
        'use_csrf' => false,
        'csrf_url' => '/sanctum/csrf-cookie',
    ],

    'auth' => [
        'enabled' => true,
        'default' => false,
        'in' => AuthIn::BEARER->value,
        'name' => 'Authorization',
        'use_value' => env('SCRIBE_AUTH_KEY'),
        'placeholder' => '{YOUR_AUTH_TOKEN}',
        'extra_info' => 'Obtain your token by calling POST `/api/v1/auth/login` or POST `/api/v1/auth/register`. Include the token in the Authorization header as `Bearer {token}`.',
    ],

    'example_languages' => [
        'bash',
        'javascript',
        'php',
    ],

    'postman' => [
        'enabled' => true,
        'overrides' => [
            'info.version' => '1.0.0',
            'info.description' => 'Preuvely API - Trusted Store Reviews Platform',
        ],
    ],

    'openapi' => [
        'enabled' => true,
        'version' => '3.0.3',
        'overrides' => [
            'info.version' => '1.0.0',
            'info.contact' => [
                'name' => 'Preuvely Support',
                'email' => 'support@preuvely.dz',
            ],
        ],
        'generators' => [],
    ],

    'groups' => [
        'default' => 'Endpoints',
        'order' => [
            'Authentication',
            'Categories',
            'Stores',
            'Reviews',
            'Store Claims',
            'Reports',
        ],
    ],

    'logo' => false,

    'last_updated' => 'Last updated: {date:F j, Y}',

    'examples' => [
        'faker_seed' => 1234,
        'models_source' => ['factoryCreate', 'factoryMake', 'databaseFirst'],
    ],

    'strategies' => [
        'metadata' => [
            ...Defaults::METADATA_STRATEGIES,
        ],
        'headers' => [
            ...Defaults::HEADERS_STRATEGIES,
            Strategies\StaticData::withSettings(data: [
                'Content-Type' => 'application/json',
                'Accept' => 'application/json',
            ]),
        ],
        'urlParameters' => [
            ...Defaults::URL_PARAMETERS_STRATEGIES,
        ],
        'queryParameters' => [
            ...Defaults::QUERY_PARAMETERS_STRATEGIES,
        ],
        'bodyParameters' => [
            ...Defaults::BODY_PARAMETERS_STRATEGIES,
        ],
        'responses' => configureStrategy(
            Defaults::RESPONSES_STRATEGIES,
            Strategies\Responses\ResponseCalls::withSettings(
                only: ['GET *'],
                config: [
                    'app.debug' => false,
                ]
            )
        ),
        'responseFields' => [
            ...Defaults::RESPONSE_FIELDS_STRATEGIES,
        ]
    ],

    'database_connections_to_transact' => [config('database.default')],

    'fractal' => [
        'serializer' => null,
    ],
];
