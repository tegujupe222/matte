#!/bin/bash

# Matte iOS App - Vercel Deployment Script
# This script helps deploy the server to Vercel

echo "🚀 Starting Matte iOS App Vercel Deployment..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Please install npm first."
    exit 1
fi

# Check if Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    echo "📦 Installing Vercel CLI..."
    npm install -g vercel
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Check if .env.local exists
if [ ! -f .env.local ]; then
    echo "⚠️  .env.local file not found. Creating template..."
    cat > .env.local << EOF
# Add your Gemini API key here
GEMINI_API_KEY=your_gemini_api_key_here
EOF
    echo "📝 Please edit .env.local and add your Gemini API key"
    echo "🔑 Get your API key from: https://aistudio.google.com/"
    read -p "Press Enter after adding your API key..."
fi

# Check if API key is set
if grep -q "your_gemini_api_key_here" .env.local; then
    echo "❌ Please add your actual Gemini API key to .env.local"
    exit 1
fi

# Deploy to Vercel
echo "🚀 Deploying to Vercel..."
vercel --prod

# Set environment variables
echo "🔧 Setting environment variables..."
vercel env add GEMINI_API_KEY

echo "✅ Deployment completed!"
echo "📱 Update your iOS app's NetworkService baseURL with the deployed URL"
echo "🔗 Check your Vercel dashboard for the deployment URL"
