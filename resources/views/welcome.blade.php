<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="Preuvely - The trusted store reviews platform for Algeria. Read and write verified reviews with proof.">
    <meta name="keywords" content="reviews, stores, Algeria, verified reviews, trusted reviews, proof">

    <!-- Open Graph -->
    <meta property="og:title" content="Preuvely - Verified Reviews">
    <meta property="og:description" content="The trusted store reviews platform for Algeria. Read and write verified reviews with proof.">
    <meta property="og:type" content="website">
    <meta property="og:url" content="{{ url('/') }}">

    <title>Preuvely - Verified Reviews</title>

    <!-- Favicon -->
    <link rel="icon" type="image/png" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>✓</text></svg>">

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=inter:400,500,600,700,800" rel="stylesheet" />

    <style>
        *, *::before, *::after {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        :root {
            --primary: #007359;
            --primary-dark: #005a46;
            --primary-light: #e6f4f1;
            --text: #1a1a1a;
            --text-secondary: #666666;
            --background: #ffffff;
            --background-secondary: #f8fafb;
            --border: #e5e7eb;
        }

        html {
            scroll-behavior: smooth;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.6;
            color: var(--text);
            background: var(--background);
        }

        /* Navigation */
        .nav {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-bottom: 1px solid var(--border);
            z-index: 1000;
            padding: 1rem 0;
        }

        .nav-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 1.5rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .logo {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            font-weight: 700;
            font-size: 1.5rem;
            color: var(--primary);
            text-decoration: none;
        }

        .logo-icon {
            width: 40px;
            height: 40px;
            background: var(--primary);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.25rem;
        }

        .nav-links {
            display: flex;
            align-items: center;
            gap: 2rem;
        }

        .nav-links a {
            color: var(--text-secondary);
            text-decoration: none;
            font-weight: 500;
            font-size: 0.95rem;
            transition: color 0.2s;
        }

        .nav-links a:hover {
            color: var(--primary);
        }

        /* Hero Section */
        .hero {
            min-height: 100vh;
            display: flex;
            align-items: center;
            padding: 8rem 1.5rem 4rem;
            background: linear-gradient(135deg, var(--background) 0%, var(--primary-light) 100%);
        }

        .hero-container {
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 4rem;
            align-items: center;
        }

        .hero-content h1 {
            font-size: 3.5rem;
            font-weight: 800;
            line-height: 1.1;
            margin-bottom: 1.5rem;
            color: var(--text);
        }

        .hero-content h1 span {
            color: var(--primary);
        }

        .hero-content p {
            font-size: 1.25rem;
            color: var(--text-secondary);
            margin-bottom: 2rem;
            max-width: 500px;
        }

        .store-buttons {
            display: flex;
            gap: 1rem;
            flex-wrap: wrap;
        }

        .store-btn {
            display: inline-flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.875rem 1.5rem;
            background: var(--text);
            color: white;
            border-radius: 12px;
            text-decoration: none;
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .store-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
        }

        .store-btn svg {
            width: 28px;
            height: 28px;
        }

        .store-btn-text {
            display: flex;
            flex-direction: column;
            align-items: flex-start;
        }

        .store-btn-text small {
            font-size: 0.7rem;
            opacity: 0.8;
        }

        .store-btn-text strong {
            font-size: 1.1rem;
            font-weight: 600;
        }

        .hero-image {
            display: flex;
            justify-content: center;
            position: relative;
        }

        .phone-mockup {
            width: 280px;
            height: 580px;
            background: linear-gradient(145deg, #1a1a1a 0%, #2d2d2d 100%);
            border-radius: 40px;
            padding: 12px;
            box-shadow: 0 50px 100px rgba(0, 0, 0, 0.25);
            position: relative;
        }

        .phone-screen {
            width: 100%;
            height: 100%;
            background: var(--background);
            border-radius: 32px;
            overflow: hidden;
            display: flex;
            flex-direction: column;
        }

        .phone-header {
            background: var(--primary);
            color: white;
            padding: 3rem 1.5rem 1.5rem;
            text-align: center;
        }

        .phone-header h3 {
            font-size: 1.25rem;
            font-weight: 700;
        }

        .phone-header p {
            font-size: 0.8rem;
            opacity: 0.9;
        }

        .phone-content {
            flex: 1;
            padding: 1rem;
            overflow: hidden;
        }

        .review-card {
            background: var(--background);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 1rem;
            margin-bottom: 0.75rem;
        }

        .review-header {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 0.5rem;
        }

        .review-avatar {
            width: 32px;
            height: 32px;
            background: var(--primary-light);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary);
            font-weight: 600;
            font-size: 0.8rem;
        }

        .review-name {
            font-weight: 600;
            font-size: 0.85rem;
        }

        .review-stars {
            color: #fbbf24;
            font-size: 0.75rem;
            letter-spacing: 2px;
        }

        .review-text {
            font-size: 0.75rem;
            color: var(--text-secondary);
            line-height: 1.4;
        }

        .verified-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.25rem;
            background: var(--primary-light);
            color: var(--primary);
            font-size: 0.65rem;
            font-weight: 600;
            padding: 0.2rem 0.5rem;
            border-radius: 20px;
            margin-top: 0.5rem;
        }

        /* Features Section */
        .features {
            padding: 6rem 1.5rem;
            background: var(--background-secondary);
        }

        .features-container {
            max-width: 1200px;
            margin: 0 auto;
        }

        .section-header {
            text-align: center;
            margin-bottom: 4rem;
        }

        .section-header h2 {
            font-size: 2.5rem;
            font-weight: 800;
            margin-bottom: 1rem;
        }

        .section-header p {
            font-size: 1.1rem;
            color: var(--text-secondary);
            max-width: 600px;
            margin: 0 auto;
        }

        .features-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 2rem;
        }

        .feature-card {
            background: var(--background);
            border-radius: 20px;
            padding: 2rem;
            text-align: center;
            transition: transform 0.3s, box-shadow 0.3s;
        }

        .feature-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
        }

        .feature-icon {
            width: 64px;
            height: 64px;
            background: var(--primary-light);
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1.5rem;
            font-size: 1.75rem;
        }

        .feature-card h3 {
            font-size: 1.25rem;
            font-weight: 700;
            margin-bottom: 0.75rem;
        }

        .feature-card p {
            color: var(--text-secondary);
            font-size: 0.95rem;
        }

        /* How it Works */
        .how-it-works {
            padding: 6rem 1.5rem;
        }

        .how-it-works-container {
            max-width: 1200px;
            margin: 0 auto;
        }

        .steps {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 2rem;
            margin-top: 3rem;
        }

        .step {
            text-align: center;
            position: relative;
        }

        .step::after {
            content: '';
            position: absolute;
            top: 2rem;
            right: -1rem;
            width: calc(100% - 4rem);
            height: 2px;
            background: var(--border);
        }

        .step:last-child::after {
            display: none;
        }

        .step-number {
            width: 4rem;
            height: 4rem;
            background: var(--primary);
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            font-weight: 700;
            margin: 0 auto 1.5rem;
            position: relative;
            z-index: 1;
        }

        .step h3 {
            font-size: 1.1rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
        }

        .step p {
            color: var(--text-secondary);
            font-size: 0.9rem;
        }

        /* CTA Section */
        .cta {
            padding: 6rem 1.5rem;
            background: var(--primary);
            color: white;
            text-align: center;
        }

        .cta-container {
            max-width: 800px;
            margin: 0 auto;
        }

        .cta h2 {
            font-size: 2.5rem;
            font-weight: 800;
            margin-bottom: 1rem;
        }

        .cta p {
            font-size: 1.2rem;
            opacity: 0.9;
            margin-bottom: 2rem;
        }

        .cta .store-buttons {
            justify-content: center;
        }

        .cta .store-btn {
            background: white;
            color: var(--text);
        }

        /* Footer */
        .footer {
            background: var(--text);
            color: white;
            padding: 4rem 1.5rem 2rem;
        }

        .footer-container {
            max-width: 1200px;
            margin: 0 auto;
        }

        .footer-top {
            display: grid;
            grid-template-columns: 2fr 1fr 1fr 1fr;
            gap: 3rem;
            padding-bottom: 3rem;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }

        .footer-brand {
            max-width: 300px;
        }

        .footer-brand .logo {
            color: white;
            margin-bottom: 1rem;
        }

        .footer-brand .logo-icon {
            background: var(--primary);
        }

        .footer-brand p {
            color: rgba(255,255,255,0.7);
            font-size: 0.9rem;
        }

        .footer-column h4 {
            font-size: 0.9rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 1.5rem;
            color: rgba(255,255,255,0.5);
        }

        .footer-column a {
            display: block;
            color: rgba(255,255,255,0.8);
            text-decoration: none;
            font-size: 0.95rem;
            margin-bottom: 0.75rem;
            transition: color 0.2s;
        }

        .footer-column a:hover {
            color: white;
        }

        .footer-bottom {
            padding-top: 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 0.85rem;
            color: rgba(255,255,255,0.5);
        }

        /* Responsive */
        @media (max-width: 1024px) {
            .hero-container {
                grid-template-columns: 1fr;
                text-align: center;
            }

            .hero-content p {
                margin-left: auto;
                margin-right: auto;
            }

            .store-buttons {
                justify-content: center;
            }

            .hero-image {
                order: -1;
            }

            .phone-mockup {
                width: 240px;
                height: 500px;
            }

            .features-grid {
                grid-template-columns: repeat(2, 1fr);
            }

            .steps {
                grid-template-columns: repeat(2, 1fr);
            }

            .step::after {
                display: none;
            }

            .footer-top {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 768px) {
            .nav-links {
                display: none;
            }

            .hero-content h1 {
                font-size: 2.5rem;
            }

            .features-grid {
                grid-template-columns: 1fr;
            }

            .steps {
                grid-template-columns: 1fr;
            }

            .footer-top {
                grid-template-columns: 1fr;
                text-align: center;
            }

            .footer-brand {
                max-width: none;
            }

            .footer-bottom {
                flex-direction: column;
                gap: 1rem;
            }
        }

        /* RTL Support */
        [dir="rtl"] .hero-container {
            direction: rtl;
        }

        /* Animations */
        @keyframes float {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }

        .phone-mockup {
            animation: float 6s ease-in-out infinite;
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="nav">
        <div class="nav-container">
            <a href="/" class="logo">
                <div class="logo-icon">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="20 6 9 17 4 12"></polyline>
                    </svg>
                </div>
                Preuvely
            </a>
            <div class="nav-links">
                <a href="#features">Features</a>
                <a href="#how-it-works">How it Works</a>
                <a href="{{ route('privacy') }}">Privacy</a>
                <a href="{{ route('terms') }}">Terms</a>
                <a href="{{ route('support') }}">Support</a>
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
    <section class="hero">
        <div class="hero-container">
            <div class="hero-content">
                <h1>
                    Trusted Reviews<br>
                    <span>With Proof</span>
                </h1>
                <p>
                    Discover verified store reviews in Algeria. Read authentic experiences backed by proof, or share your own to help the community make informed decisions.
                </p>
                <div class="store-buttons">
                    <a href="https://apps.apple.com/app/preuvely-verified-reviews/id6740043553" class="store-btn" target="_blank">
                        <svg viewBox="0 0 24 24" fill="currentColor">
                            <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
                        </svg>
                        <div class="store-btn-text">
                            <small>Download on the</small>
                            <strong>App Store</strong>
                        </div>
                    </a>
                    <a href="https://play.google.com/store/apps/details?id=com.preuvely.app" class="store-btn" target="_blank">
                        <svg viewBox="0 0 24 24" fill="currentColor">
                            <path d="M3,20.5V3.5C3,2.91 3.34,2.39 3.84,2.15L13.69,12L3.84,21.85C3.34,21.6 3,21.09 3,20.5M16.81,15.12L6.05,21.34L14.54,12.85L16.81,15.12M20.16,10.81C20.5,11.08 20.75,11.5 20.75,12C20.75,12.5 20.53,12.9 20.18,13.18L17.89,14.5L15.39,12L17.89,9.5L20.16,10.81M6.05,2.66L16.81,8.88L14.54,11.15L6.05,2.66Z"/>
                        </svg>
                        <div class="store-btn-text">
                            <small>Get it on</small>
                            <strong>Google Play</strong>
                        </div>
                    </a>
                </div>
            </div>
            <div class="hero-image">
                <div class="phone-mockup">
                    <div class="phone-screen">
                        <div class="phone-header">
                            <h3>Preuvely</h3>
                            <p>Verified Reviews</p>
                        </div>
                        <div class="phone-content">
                            <div class="review-card">
                                <div class="review-header">
                                    <div class="review-avatar">S</div>
                                    <div>
                                        <div class="review-name">Sarah M.</div>
                                        <div class="review-stars">★★★★★</div>
                                    </div>
                                </div>
                                <p class="review-text">Great quality products and fast delivery! Highly recommended.</p>
                                <div class="verified-badge">
                                    <svg width="12" height="12" viewBox="0 0 24 24" fill="currentColor"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
                                    Verified Purchase
                                </div>
                            </div>
                            <div class="review-card">
                                <div class="review-header">
                                    <div class="review-avatar">A</div>
                                    <div>
                                        <div class="review-name">Ahmed K.</div>
                                        <div class="review-stars">★★★★☆</div>
                                    </div>
                                </div>
                                <p class="review-text">Good service, reasonable prices. Will buy again.</p>
                                <div class="verified-badge">
                                    <svg width="12" height="12" viewBox="0 0 24 24" fill="currentColor"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
                                    Verified Purchase
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Features Section -->
    <section id="features" class="features">
        <div class="features-container">
            <div class="section-header">
                <h2>Why Choose Preuvely?</h2>
                <p>We're building trust in online shopping through verified, authentic reviews backed by real proof.</p>
            </div>
            <div class="features-grid">
                <div class="feature-card">
                    <div class="feature-icon">🛡️</div>
                    <h3>Verified Reviews</h3>
                    <p>Every review can be backed by proof of purchase, ensuring authenticity and trust.</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">⭐</div>
                    <h3>Honest Ratings</h3>
                    <p>Real experiences from real customers. No fake reviews, no paid endorsements.</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">🔍</div>
                    <h3>Smart Search</h3>
                    <p>Find stores by name, Instagram handle, phone number, or website URL.</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">🏪</div>
                    <h3>Store Profiles</h3>
                    <p>Complete store information with social links, contact details, and categories.</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">💬</div>
                    <h3>Owner Responses</h3>
                    <p>Store owners can verify their business and respond to customer reviews.</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">🔒</div>
                    <h3>Privacy First</h3>
                    <p>Your data is protected. We never share your personal information.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- How it Works -->
    <section id="how-it-works" class="how-it-works">
        <div class="how-it-works-container">
            <div class="section-header">
                <h2>How It Works</h2>
                <p>Getting started with Preuvely is simple and takes just a few minutes.</p>
            </div>
            <div class="steps">
                <div class="step">
                    <div class="step-number">1</div>
                    <h3>Download the App</h3>
                    <p>Get Preuvely from the App Store or Google Play for free.</p>
                </div>
                <div class="step">
                    <div class="step-number">2</div>
                    <h3>Find a Store</h3>
                    <p>Search for stores by name, social media, or browse categories.</p>
                </div>
                <div class="step">
                    <div class="step-number">3</div>
                    <h3>Read Reviews</h3>
                    <p>Check out verified reviews and ratings from other shoppers.</p>
                </div>
                <div class="step">
                    <div class="step-number">4</div>
                    <h3>Share Your Experience</h3>
                    <p>Write a review and upload proof to help the community.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- CTA Section -->
    <section class="cta">
        <div class="cta-container">
            <h2>Start Making Informed Decisions</h2>
            <p>Join thousands of shoppers who trust Preuvely for authentic store reviews.</p>
            <div class="store-buttons">
                <a href="https://apps.apple.com/app/preuvely-verified-reviews/id6740043553" class="store-btn" target="_blank">
                    <svg viewBox="0 0 24 24" fill="currentColor">
                        <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
                    </svg>
                    <div class="store-btn-text">
                        <small>Download on the</small>
                        <strong>App Store</strong>
                    </div>
                </a>
                <a href="https://play.google.com/store/apps/details?id=com.preuvely.app" class="store-btn" target="_blank">
                    <svg viewBox="0 0 24 24" fill="currentColor">
                        <path d="M3,20.5V3.5C3,2.91 3.34,2.39 3.84,2.15L13.69,12L3.84,21.85C3.34,21.6 3,21.09 3,20.5M16.81,15.12L6.05,21.34L14.54,12.85L16.81,15.12M20.16,10.81C20.5,11.08 20.75,11.5 20.75,12C20.75,12.5 20.53,12.9 20.18,13.18L17.89,14.5L15.39,12L17.89,9.5L20.16,10.81M6.05,2.66L16.81,8.88L14.54,11.15L6.05,2.66Z"/>
                    </svg>
                    <div class="store-btn-text">
                        <small>Get it on</small>
                        <strong>Google Play</strong>
                    </div>
                </a>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="footer">
        <div class="footer-container">
            <div class="footer-top">
                <div class="footer-brand">
                    <a href="/" class="logo">
                        <div class="logo-icon">
                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                <polyline points="20 6 9 17 4 12"></polyline>
                            </svg>
                        </div>
                        Preuvely
                    </a>
                    <p>The trusted store reviews platform for Algeria. Building trust through verified reviews.</p>
                </div>
                <div class="footer-column">
                    <h4>Product</h4>
                    <a href="#features">Features</a>
                    <a href="#how-it-works">How it Works</a>
                </div>
                <div class="footer-column">
                    <h4>Legal</h4>
                    <a href="{{ route('privacy') }}">Privacy Policy</a>
                    <a href="{{ route('terms') }}">Terms of Service</a>
                    <a href="{{ route('delete-account') }}">Delete Account</a>
                </div>
                <div class="footer-column">
                    <h4>Support</h4>
                    <a href="{{ route('support') }}">Help Center</a>
                    <a href="mailto:support@preuvely.com">Contact Us</a>
                </div>
            </div>
            <div class="footer-bottom">
                <p>&copy; {{ date('Y') }} Preuvely. All rights reserved.</p>
                <p>Made with ❤️ in Algeria</p>
            </div>
        </div>
    </footer>
</body>
</html>
