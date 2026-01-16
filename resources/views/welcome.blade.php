<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="Preuvely - The trusted store reviews platform for Algeria. Read and write verified reviews with proof.">

    <!-- Open Graph -->
    <meta property="og:title" content="Preuvely - Verified Reviews">
    <meta property="og:description" content="The trusted store reviews platform for Algeria. Read and write verified reviews with proof.">
    <meta property="og:type" content="website">

    <title>Preuvely - Verified Reviews</title>

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        :root {
            --primary: #00A67E;
            --primary-dark: #008F6B;
            --primary-light: #00D9A5;
            --accent: #7C3AED;
            --accent-light: #A78BFA;
            --dark: #0F172A;
            --dark-light: #1E293B;
            --gray: #64748B;
            --light: #F8FAFC;
            --white: #FFFFFF;
        }

        html {
            scroll-behavior: smooth;
        }

        body {
            font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif;
            background: var(--dark);
            color: var(--white);
            overflow-x: hidden;
        }

        /* Animated Background */
        .bg-gradient {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background:
                radial-gradient(ellipse 80% 50% at 50% -20%, rgba(0, 166, 126, 0.3), transparent),
                radial-gradient(ellipse 60% 40% at 100% 50%, rgba(124, 58, 237, 0.2), transparent),
                radial-gradient(ellipse 50% 30% at 0% 80%, rgba(0, 217, 165, 0.15), transparent);
            pointer-events: none;
            z-index: 0;
        }

        .content {
            position: relative;
            z-index: 1;
        }

        /* Floating Orbs */
        .orb {
            position: absolute;
            border-radius: 50%;
            filter: blur(60px);
            opacity: 0.5;
            animation: float 20s ease-in-out infinite;
        }

        .orb-1 {
            width: 400px;
            height: 400px;
            background: var(--primary);
            top: 10%;
            left: -10%;
            animation-delay: 0s;
        }

        .orb-2 {
            width: 300px;
            height: 300px;
            background: var(--accent);
            top: 60%;
            right: -5%;
            animation-delay: -5s;
        }

        .orb-3 {
            width: 200px;
            height: 200px;
            background: var(--primary-light);
            bottom: 10%;
            left: 30%;
            animation-delay: -10s;
        }

        @keyframes float {
            0%, 100% { transform: translate(0, 0) scale(1); }
            33% { transform: translate(30px, -30px) scale(1.05); }
            66% { transform: translate(-20px, 20px) scale(0.95); }
        }

        /* Navigation */
        .nav {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 100;
            padding: 1.25rem 2rem;
            transition: all 0.3s ease;
        }

        .nav.scrolled {
            background: rgba(15, 23, 42, 0.8);
            backdrop-filter: blur(20px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .nav-container {
            max-width: 1400px;
            margin: 0 auto;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .logo {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            text-decoration: none;
            color: var(--white);
        }

        .logo-icon {
            width: 48px;
            height: 48px;
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 10px 40px rgba(0, 166, 126, 0.3);
        }

        .logo-text {
            font-size: 1.5rem;
            font-weight: 800;
            background: linear-gradient(135deg, var(--white) 0%, var(--gray) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .nav-links {
            display: flex;
            align-items: center;
            gap: 2.5rem;
        }

        .nav-links a {
            color: rgba(255, 255, 255, 0.7);
            text-decoration: none;
            font-weight: 500;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            position: relative;
        }

        .nav-links a::after {
            content: '';
            position: absolute;
            bottom: -4px;
            left: 0;
            width: 0;
            height: 2px;
            background: var(--primary);
            transition: width 0.3s ease;
        }

        .nav-links a:hover {
            color: var(--white);
        }

        .nav-links a:hover::after {
            width: 100%;
        }

        .nav-cta {
            padding: 0.75rem 1.5rem;
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            border-radius: 12px;
            color: var(--white) !important;
            font-weight: 600;
            box-shadow: 0 4px 20px rgba(0, 166, 126, 0.4);
            transition: all 0.3s ease;
        }

        .nav-cta:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 30px rgba(0, 166, 126, 0.5);
        }

        .nav-cta::after {
            display: none !important;
        }

        /* Hero Section */
        .hero {
            min-height: 100vh;
            display: flex;
            align-items: center;
            padding: 8rem 2rem 4rem;
            position: relative;
        }

        .hero-container {
            max-width: 1400px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 4rem;
            align-items: center;
        }

        .hero-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 1rem;
            background: rgba(0, 166, 126, 0.1);
            border: 1px solid rgba(0, 166, 126, 0.3);
            border-radius: 100px;
            font-size: 0.85rem;
            color: var(--primary-light);
            margin-bottom: 1.5rem;
            animation: fadeInUp 0.8s ease;
        }

        .hero-badge span {
            width: 8px;
            height: 8px;
            background: var(--primary-light);
            border-radius: 50%;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; transform: scale(1); }
            50% { opacity: 0.5; transform: scale(1.2); }
        }

        .hero-title {
            font-size: 4.5rem;
            font-weight: 800;
            line-height: 1.1;
            margin-bottom: 1.5rem;
            animation: fadeInUp 0.8s ease 0.1s backwards;
        }

        .hero-title .gradient-text {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 50%, var(--accent-light) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .hero-description {
            font-size: 1.25rem;
            color: var(--gray);
            line-height: 1.7;
            margin-bottom: 2.5rem;
            max-width: 500px;
            animation: fadeInUp 0.8s ease 0.2s backwards;
        }

        .hero-buttons {
            display: flex;
            gap: 1rem;
            flex-wrap: wrap;
            animation: fadeInUp 0.8s ease 0.3s backwards;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            gap: 0.75rem;
            padding: 1rem 2rem;
            border-radius: 16px;
            text-decoration: none;
            font-weight: 600;
            font-size: 1rem;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            color: var(--white);
            box-shadow: 0 10px 40px rgba(0, 166, 126, 0.4);
        }

        .btn-primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 50px rgba(0, 166, 126, 0.5);
        }

        .btn-secondary {
            background: rgba(255, 255, 255, 0.05);
            color: var(--white);
            border: 1px solid rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
        }

        .btn-secondary:hover {
            background: rgba(255, 255, 255, 0.1);
            border-color: rgba(255, 255, 255, 0.2);
        }

        .btn svg {
            width: 24px;
            height: 24px;
        }

        /* Hero Phone */
        .hero-visual {
            position: relative;
            display: flex;
            justify-content: center;
            animation: fadeInUp 0.8s ease 0.4s backwards;
        }

        .phone-wrapper {
            position: relative;
        }

        .phone-glow {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 300px;
            height: 500px;
            background: linear-gradient(135deg, var(--primary) 0%, var(--accent) 100%);
            filter: blur(80px);
            opacity: 0.4;
            border-radius: 50%;
        }

        .phone {
            position: relative;
            width: 280px;
            height: 580px;
            background: linear-gradient(145deg, #2D3748 0%, #1A202C 100%);
            border-radius: 44px;
            padding: 8px;
            box-shadow:
                0 50px 100px rgba(0, 0, 0, 0.5),
                inset 0 1px 0 rgba(255, 255, 255, 0.1);
        }

        .phone-screen {
            width: 100%;
            height: 100%;
            background: var(--dark);
            border-radius: 38px;
            overflow: hidden;
            position: relative;
        }

        .phone-notch {
            position: absolute;
            top: 8px;
            left: 50%;
            transform: translateX(-50%);
            width: 100px;
            height: 28px;
            background: #000;
            border-radius: 20px;
            z-index: 10;
        }

        .phone-content {
            padding: 3rem 1rem 1rem;
            height: 100%;
            display: flex;
            flex-direction: column;
        }

        .app-header {
            text-align: center;
            padding: 1rem;
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            border-radius: 20px;
            margin-bottom: 1rem;
        }

        .app-header h3 {
            font-size: 1.1rem;
            font-weight: 700;
            margin-bottom: 0.25rem;
        }

        .app-header p {
            font-size: 0.75rem;
            opacity: 0.8;
        }

        .app-reviews {
            flex: 1;
            overflow: hidden;
        }

        .mini-review {
            background: var(--dark-light);
            border-radius: 16px;
            padding: 0.875rem;
            margin-bottom: 0.75rem;
            border: 1px solid rgba(255, 255, 255, 0.05);
        }

        .mini-review-header {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 0.5rem;
        }

        .mini-avatar {
            width: 28px;
            height: 28px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--primary) 0%, var(--accent) 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.7rem;
            font-weight: 700;
        }

        .mini-name {
            font-size: 0.8rem;
            font-weight: 600;
        }

        .mini-stars {
            margin-left: auto;
            color: #FBBF24;
            font-size: 0.7rem;
        }

        .mini-text {
            font-size: 0.7rem;
            color: var(--gray);
            line-height: 1.4;
        }

        .mini-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.25rem;
            margin-top: 0.5rem;
            padding: 0.2rem 0.5rem;
            background: rgba(0, 166, 126, 0.1);
            border-radius: 20px;
            font-size: 0.6rem;
            color: var(--primary-light);
        }

        /* Floating Elements */
        .floating-card {
            position: absolute;
            background: rgba(30, 41, 59, 0.8);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 16px;
            padding: 1rem;
            animation: floatCard 6s ease-in-out infinite;
        }

        .floating-card-1 {
            top: 10%;
            right: -20px;
            animation-delay: 0s;
        }

        .floating-card-2 {
            bottom: 15%;
            left: -30px;
            animation-delay: -3s;
        }

        @keyframes floatCard {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-15px); }
        }

        .floating-stat {
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .floating-stat-icon {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .floating-stat-text h4 {
            font-size: 1.1rem;
            font-weight: 700;
        }

        .floating-stat-text p {
            font-size: 0.75rem;
            color: var(--gray);
        }

        /* Stats Section */
        .stats {
            padding: 4rem 2rem;
            position: relative;
        }

        .stats-container {
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 2rem;
        }

        .stat-card {
            text-align: center;
            padding: 2rem;
            background: rgba(255, 255, 255, 0.02);
            border: 1px solid rgba(255, 255, 255, 0.05);
            border-radius: 24px;
            transition: all 0.3s ease;
        }

        .stat-card:hover {
            background: rgba(255, 255, 255, 0.05);
            transform: translateY(-5px);
        }

        .stat-number {
            font-size: 3rem;
            font-weight: 800;
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 0.5rem;
        }

        .stat-label {
            color: var(--gray);
            font-size: 0.95rem;
        }

        /* Features Section */
        .features {
            padding: 8rem 2rem;
            position: relative;
        }

        .section-header {
            text-align: center;
            max-width: 700px;
            margin: 0 auto 5rem;
        }

        .section-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 1rem;
            background: rgba(124, 58, 237, 0.1);
            border: 1px solid rgba(124, 58, 237, 0.3);
            border-radius: 100px;
            font-size: 0.85rem;
            color: var(--accent-light);
            margin-bottom: 1.5rem;
        }

        .section-title {
            font-size: 3rem;
            font-weight: 800;
            margin-bottom: 1rem;
        }

        .section-description {
            font-size: 1.15rem;
            color: var(--gray);
            line-height: 1.7;
        }

        .features-grid {
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1.5rem;
        }

        .feature-card {
            background: rgba(255, 255, 255, 0.02);
            border: 1px solid rgba(255, 255, 255, 0.05);
            border-radius: 24px;
            padding: 2rem;
            transition: all 0.4s ease;
            position: relative;
            overflow: hidden;
        }

        .feature-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 2px;
            background: linear-gradient(90deg, transparent, var(--primary), transparent);
            opacity: 0;
            transition: opacity 0.4s ease;
        }

        .feature-card:hover {
            background: rgba(255, 255, 255, 0.05);
            transform: translateY(-8px);
            border-color: rgba(0, 166, 126, 0.3);
        }

        .feature-card:hover::before {
            opacity: 1;
        }

        .feature-icon {
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, rgba(0, 166, 126, 0.2) 0%, rgba(0, 166, 126, 0.05) 100%);
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.75rem;
            margin-bottom: 1.5rem;
        }

        .feature-card h3 {
            font-size: 1.25rem;
            font-weight: 700;
            margin-bottom: 0.75rem;
        }

        .feature-card p {
            color: var(--gray);
            font-size: 0.95rem;
            line-height: 1.6;
        }

        /* Testimonials */
        .testimonials {
            padding: 8rem 2rem;
            background: rgba(0, 0, 0, 0.2);
        }

        .testimonials-grid {
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1.5rem;
        }

        .testimonial-card {
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid rgba(255, 255, 255, 0.05);
            border-radius: 24px;
            padding: 2rem;
            transition: all 0.3s ease;
        }

        .testimonial-card:hover {
            background: rgba(255, 255, 255, 0.05);
        }

        .testimonial-stars {
            color: #FBBF24;
            font-size: 1.1rem;
            margin-bottom: 1rem;
        }

        .testimonial-text {
            font-size: 1.05rem;
            line-height: 1.7;
            margin-bottom: 1.5rem;
            color: rgba(255, 255, 255, 0.9);
        }

        .testimonial-author {
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .testimonial-avatar {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--primary) 0%, var(--accent) 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
        }

        .testimonial-name {
            font-weight: 600;
        }

        .testimonial-role {
            font-size: 0.85rem;
            color: var(--gray);
        }

        /* CTA Section */
        .cta {
            padding: 8rem 2rem;
            position: relative;
            overflow: hidden;
        }

        .cta-container {
            max-width: 900px;
            margin: 0 auto;
            text-align: center;
            position: relative;
            z-index: 1;
        }

        .cta-bg {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 600px;
            height: 600px;
            background: radial-gradient(circle, rgba(0, 166, 126, 0.3) 0%, transparent 70%);
            filter: blur(60px);
        }

        .cta h2 {
            font-size: 3.5rem;
            font-weight: 800;
            margin-bottom: 1.5rem;
        }

        .cta p {
            font-size: 1.25rem;
            color: var(--gray);
            margin-bottom: 2.5rem;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
        }

        .cta-buttons {
            display: flex;
            gap: 1rem;
            justify-content: center;
            flex-wrap: wrap;
        }

        .store-btn {
            display: inline-flex;
            align-items: center;
            gap: 0.875rem;
            padding: 1rem 1.75rem;
            background: var(--white);
            color: var(--dark);
            border-radius: 16px;
            text-decoration: none;
            transition: all 0.3s ease;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
        }

        .store-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 50px rgba(0, 0, 0, 0.4);
        }

        .store-btn svg {
            width: 32px;
            height: 32px;
        }

        .store-btn-text {
            text-align: left;
        }

        .store-btn-text small {
            font-size: 0.7rem;
            color: var(--gray);
            display: block;
        }

        .store-btn-text strong {
            font-size: 1.15rem;
            font-weight: 700;
        }

        /* Footer */
        .footer {
            padding: 5rem 2rem 2rem;
            border-top: 1px solid rgba(255, 255, 255, 0.05);
        }

        .footer-container {
            max-width: 1200px;
            margin: 0 auto;
        }

        .footer-top {
            display: grid;
            grid-template-columns: 2fr 1fr 1fr 1fr;
            gap: 4rem;
            padding-bottom: 4rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
        }

        .footer-brand p {
            color: var(--gray);
            margin-top: 1rem;
            font-size: 0.95rem;
            line-height: 1.7;
            max-width: 300px;
        }

        .footer-column h4 {
            font-size: 0.85rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: var(--gray);
            margin-bottom: 1.5rem;
        }

        .footer-column a {
            display: block;
            color: rgba(255, 255, 255, 0.7);
            text-decoration: none;
            font-size: 0.95rem;
            margin-bottom: 0.875rem;
            transition: all 0.3s ease;
        }

        .footer-column a:hover {
            color: var(--primary-light);
            transform: translateX(5px);
        }

        .footer-bottom {
            padding-top: 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: var(--gray);
            font-size: 0.9rem;
        }

        .footer-bottom a {
            color: var(--primary-light);
            text-decoration: none;
        }

        /* Animations */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Responsive */
        @media (max-width: 1024px) {
            .hero-container {
                grid-template-columns: 1fr;
                text-align: center;
            }

            .hero-title {
                font-size: 3rem;
            }

            .hero-description {
                margin-left: auto;
                margin-right: auto;
            }

            .hero-buttons {
                justify-content: center;
            }

            .hero-visual {
                margin-top: 3rem;
            }

            .floating-card {
                display: none;
            }

            .stats-container {
                grid-template-columns: repeat(2, 1fr);
            }

            .features-grid,
            .testimonials-grid {
                grid-template-columns: repeat(2, 1fr);
            }

            .footer-top {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 768px) {
            .nav-links {
                display: none;
            }

            .hero {
                padding: 6rem 1.5rem 3rem;
            }

            .hero-title {
                font-size: 2.25rem;
            }

            .section-title {
                font-size: 2rem;
            }

            .stats-container,
            .features-grid,
            .testimonials-grid {
                grid-template-columns: 1fr;
            }

            .cta h2 {
                font-size: 2rem;
            }

            .footer-top {
                grid-template-columns: 1fr;
                text-align: center;
            }

            .footer-brand p {
                max-width: none;
            }

            .footer-bottom {
                flex-direction: column;
                gap: 1rem;
            }

            .phone {
                width: 240px;
                height: 500px;
            }
        }

        /* Mobile Menu Toggle */
        .mobile-menu-btn {
            display: none;
            background: none;
            border: none;
            color: var(--white);
            cursor: pointer;
            padding: 0.5rem;
        }

        @media (max-width: 768px) {
            .mobile-menu-btn {
                display: block;
            }
        }
    </style>
</head>
<body>
    <div class="bg-gradient"></div>

    <div class="orb orb-1"></div>
    <div class="orb orb-2"></div>
    <div class="orb orb-3"></div>

    <div class="content">
        <!-- Navigation -->
        <nav class="nav" id="nav">
            <div class="nav-container">
                <a href="/" class="logo">
                    <div class="logo-icon">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                            <polyline points="20 6 9 17 4 12"></polyline>
                        </svg>
                    </div>
                    <span class="logo-text">Preuvely</span>
                </a>
                <div class="nav-links">
                    <a href="#features">Features</a>
                    <a href="#testimonials">Reviews</a>
                    <a href="{{ route('privacy') }}">Privacy</a>
                    <a href="{{ route('support') }}">Support</a>
                    <a href="#download" class="nav-cta">Download</a>
                </div>
                <button class="mobile-menu-btn">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <line x1="3" y1="12" x2="21" y2="12"></line>
                        <line x1="3" y1="6" x2="21" y2="6"></line>
                        <line x1="3" y1="18" x2="21" y2="18"></line>
                    </svg>
                </button>
            </div>
        </nav>

        <!-- Hero Section -->
        <section class="hero">
            <div class="hero-container">
                <div class="hero-content">
                    <div class="hero-badge">
                        <span></span>
                        Now available on iOS & Android
                    </div>
                    <h1 class="hero-title">
                        Shop Smart with<br>
                        <span class="gradient-text">Verified Reviews</span>
                    </h1>
                    <p class="hero-description">
                        Join Algeria's most trusted store review platform. Read authentic experiences backed by real proof, and help others make confident shopping decisions.
                    </p>
                    <div class="hero-buttons">
                        <a href="https://apps.apple.com/app/preuvely-verified-reviews/id6740043553" class="btn btn-primary" target="_blank">
                            <svg viewBox="0 0 24 24" fill="currentColor">
                                <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
                            </svg>
                            Download for iOS
                        </a>
                        <a href="https://play.google.com/store/apps/details?id=com.preuvely.app" class="btn btn-secondary" target="_blank">
                            <svg viewBox="0 0 24 24" fill="currentColor">
                                <path d="M3,20.5V3.5C3,2.91 3.34,2.39 3.84,2.15L13.69,12L3.84,21.85C3.34,21.6 3,21.09 3,20.5M16.81,15.12L6.05,21.34L14.54,12.85L16.81,15.12M20.16,10.81C20.5,11.08 20.75,11.5 20.75,12C20.75,12.5 20.53,12.9 20.18,13.18L17.89,14.5L15.39,12L17.89,9.5L20.16,10.81M6.05,2.66L16.81,8.88L14.54,11.15L6.05,2.66Z"/>
                            </svg>
                            Get on Android
                        </a>
                    </div>
                </div>
                <div class="hero-visual">
                    <div class="phone-wrapper">
                        <div class="phone-glow"></div>
                        <div class="phone">
                            <div class="phone-screen">
                                <div class="phone-notch"></div>
                                <div class="phone-content">
                                    <div class="app-header">
                                        <h3>Preuvely</h3>
                                        <p>Trusted Reviews</p>
                                    </div>
                                    <div class="app-reviews">
                                        <div class="mini-review">
                                            <div class="mini-review-header">
                                                <div class="mini-avatar">S</div>
                                                <span class="mini-name">Sarah M.</span>
                                                <span class="mini-stars">★★★★★</span>
                                            </div>
                                            <p class="mini-text">Amazing quality! Fast delivery and great customer service.</p>
                                            <div class="mini-badge">
                                                <svg width="10" height="10" viewBox="0 0 24 24" fill="currentColor"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
                                                Verified
                                            </div>
                                        </div>
                                        <div class="mini-review">
                                            <div class="mini-review-header">
                                                <div class="mini-avatar">A</div>
                                                <span class="mini-name">Ahmed K.</span>
                                                <span class="mini-stars">★★★★☆</span>
                                            </div>
                                            <p class="mini-text">Good products, reasonable prices. Recommended!</p>
                                            <div class="mini-badge">
                                                <svg width="10" height="10" viewBox="0 0 24 24" fill="currentColor"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
                                                Verified
                                            </div>
                                        </div>
                                        <div class="mini-review">
                                            <div class="mini-review-header">
                                                <div class="mini-avatar">L</div>
                                                <span class="mini-name">Lina B.</span>
                                                <span class="mini-stars">★★★★★</span>
                                            </div>
                                            <p class="mini-text">Best online store I've found!</p>
                                            <div class="mini-badge">
                                                <svg width="10" height="10" viewBox="0 0 24 24" fill="currentColor"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
                                                Verified
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="floating-card floating-card-1">
                            <div class="floating-stat">
                                <div class="floating-stat-icon">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="white"><path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/></svg>
                                </div>
                                <div class="floating-stat-text">
                                    <h4>4.9 Rating</h4>
                                    <p>App Store</p>
                                </div>
                            </div>
                        </div>
                        <div class="floating-card floating-card-2">
                            <div class="floating-stat">
                                <div class="floating-stat-icon">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="white"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>
                                </div>
                                <div class="floating-stat-text">
                                    <h4>10K+</h4>
                                    <p>Active Users</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Stats Section -->
        <section class="stats">
            <div class="stats-container">
                <div class="stat-card">
                    <div class="stat-number">50K+</div>
                    <div class="stat-label">Verified Reviews</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">5K+</div>
                    <div class="stat-label">Stores Listed</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">10K+</div>
                    <div class="stat-label">Happy Users</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">4.9</div>
                    <div class="stat-label">App Rating</div>
                </div>
            </div>
        </section>

        <!-- Features Section -->
        <section id="features" class="features">
            <div class="section-header">
                <div class="section-badge">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg>
                    Powerful Features
                </div>
                <h2 class="section-title">Everything You Need</h2>
                <p class="section-description">
                    Preuvely gives you all the tools to make informed shopping decisions and share your experiences with the community.
                </p>
            </div>
            <div class="features-grid">
                <div class="feature-card">
                    <div class="feature-icon">🛡️</div>
                    <h3>Proof-Based Reviews</h3>
                    <p>Every review can include photo proof of purchase, ensuring authenticity you can trust.</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">🔍</div>
                    <h3>Smart Search</h3>
                    <p>Find any store by name, Instagram handle, phone number, or website URL instantly.</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">⭐</div>
                    <h3>Honest Ratings</h3>
                    <p>Real ratings from real customers. No fake reviews, no paid endorsements.</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">💬</div>
                    <h3>Owner Responses</h3>
                    <p>Verified store owners can respond to reviews and engage with customers.</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">🏪</div>
                    <h3>Complete Profiles</h3>
                    <p>Full store info with social links, contact details, location, and categories.</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">🔒</div>
                    <h3>Privacy First</h3>
                    <p>Your data stays private. We never share or sell your personal information.</p>
                </div>
            </div>
        </section>

        <!-- Testimonials -->
        <section id="testimonials" class="testimonials">
            <div class="section-header">
                <div class="section-badge">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg>
                    User Reviews
                </div>
                <h2 class="section-title">Loved by Thousands</h2>
                <p class="section-description">
                    See what our community has to say about their experience with Preuvely.
                </p>
            </div>
            <div class="testimonials-grid">
                <div class="testimonial-card">
                    <div class="testimonial-stars">★★★★★</div>
                    <p class="testimonial-text">"Finally an app where I can trust the reviews! The proof feature is genius. Saved me from several bad purchases."</p>
                    <div class="testimonial-author">
                        <div class="testimonial-avatar">F</div>
                        <div>
                            <div class="testimonial-name">Fatima Z.</div>
                            <div class="testimonial-role">Algiers</div>
                        </div>
                    </div>
                </div>
                <div class="testimonial-card">
                    <div class="testimonial-stars">★★★★★</div>
                    <p class="testimonial-text">"As a store owner, Preuvely helped me build trust with customers. The verified badge makes a real difference!"</p>
                    <div class="testimonial-author">
                        <div class="testimonial-avatar">K</div>
                        <div>
                            <div class="testimonial-name">Karim M.</div>
                            <div class="testimonial-role">Store Owner, Oran</div>
                        </div>
                    </div>
                </div>
                <div class="testimonial-card">
                    <div class="testimonial-stars">★★★★★</div>
                    <p class="testimonial-text">"The smart search is amazing! I just paste an Instagram link and find the store instantly. So convenient!"</p>
                    <div class="testimonial-author">
                        <div class="testimonial-avatar">N</div>
                        <div>
                            <div class="testimonial-name">Nadia B.</div>
                            <div class="testimonial-role">Constantine</div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- CTA Section -->
        <section id="download" class="cta">
            <div class="cta-bg"></div>
            <div class="cta-container">
                <h2>Ready to Shop Smarter?</h2>
                <p>Download Preuvely now and join thousands of smart shoppers making informed decisions every day.</p>
                <div class="cta-buttons">
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
                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                    <polyline points="20 6 9 17 4 12"></polyline>
                                </svg>
                            </div>
                            <span class="logo-text">Preuvely</span>
                        </a>
                        <p>Algeria's trusted platform for verified store reviews. Building trust in online shopping, one review at a time.</p>
                    </div>
                    <div class="footer-column">
                        <h4>Product</h4>
                        <a href="#features">Features</a>
                        <a href="#testimonials">Reviews</a>
                        <a href="#download">Download</a>
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
                    <p>Made with ❤️ in <a href="#">Algeria</a></p>
                </div>
            </div>
        </footer>
    </div>

    <script>
        // Navbar scroll effect
        const nav = document.getElementById('nav');
        window.addEventListener('scroll', () => {
            if (window.scrollY > 50) {
                nav.classList.add('scrolled');
            } else {
                nav.classList.remove('scrolled');
            }
        });

        // Smooth scroll for anchor links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });
    </script>
</body>
</html>
