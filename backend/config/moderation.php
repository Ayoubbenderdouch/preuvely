<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Banned Words List
    |--------------------------------------------------------------------------
    |
    | A list of words that are not allowed in reviews, replies, and other
    | user-generated content. This is a basic profanity filter.
    |
    */
    'banned_words' => [
        // Add your banned words here
        // These are examples - add real offensive words as needed
        'scam',
        'fraud',
        'arnaque',
        'voleur',
        'نصب',
        'احتيال',
    ],

    /*
    |--------------------------------------------------------------------------
    | Rate Limits
    |--------------------------------------------------------------------------
    |
    | Configure rate limits for various user actions.
    |
    */
    'rate_limits' => [
        'reviews_per_day' => 5,
        'stores_per_day' => 10,
        'reports_per_day' => 10,
    ],
];
