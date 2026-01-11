# Introduction

API for Preuvely - Trusted Store Reviews Platform for Algeria

<aside>
    <strong>Base URL</strong>: <code>http://localhost</code>
</aside>

    Welcome to the Preuvely API documentation!

    Preuvely is a trust/review directory for online stores in Algeria. Users can search stores, view ratings, and leave reviews with star ratings and comments.

    ## Authentication
    This API uses Laravel Sanctum for authentication. To authenticate:
    1. Register or login to get a bearer token
    2. Include the token in the Authorization header: `Bearer {YOUR_TOKEN}`

    ## High-Risk Categories
    Some categories (digital services, USDT, gift cards) are considered high-risk. Reviews for stores in these categories require proof uploads and admin approval before becoming visible.

    <aside>As you scroll, you'll see code examples for working with the API in the dark area to the right (or as part of the content on mobile).</aside>

