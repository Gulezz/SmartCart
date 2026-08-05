/** @type {import('next').NextConfig} */

const isDev  = process.env.NODE_ENV === 'development'
const hstsOn = process.env.HSTS_ENABLED === 'true'

const pusherCluster = process.env.NEXT_PUBLIC_PUSHER_CLUSTER ?? 'eu'
const pusherWsHost  = `wss://ws-${pusherCluster}.pusher.com`
const pusherApiHost = `https://sockjs-${pusherCluster}.pusher.com`

const cspDirectives = [
  "default-src 'self'",
  `script-src 'self' https://js.pusher.com https://cdnjs.cloudflare.com`,
  `style-src 'self' 'unsafe-inline'`,
  `font-src 'self' data:`,
  `img-src 'self' data: https://lh3.googleusercontent.com https://avatars.githubusercontent.com https://tile.openstreetmap.org https://*.tile.openstreetmap.org`,
  `connect-src 'self' ${pusherWsHost} ${pusherApiHost} https://stats.pusher.com https://*.upstash.io`,
  `frame-ancestors 'none'`,
  ...(isDev ? [] : [`upgrade-insecure-requests`]),
].join('; ')

const nextConfig = {
  reactStrictMode: true,
  outputFileTracingRoot: __dirname,

  images: {
    remotePatterns: [
      { protocol: 'https', hostname: 'lh3.googleusercontent.com' },
      { protocol: 'https', hostname: 'avatars.githubusercontent.com' },
    ],
  },

  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          { key: 'Content-Security-Policy',   value: cspDirectives },
          ...(hstsOn ? [{ key: 'Strict-Transport-Security', value: 'max-age=63072000; includeSubDomains' }] : []),
          { key: 'X-Content-Type-Options',    value: 'nosniff' },
          { key: 'X-Frame-Options',           value: 'DENY' },
          { key: 'Referrer-Policy',           value: 'strict-origin-when-cross-origin' },
          { key: 'Permissions-Policy',        value: 'camera=(), microphone=(), geolocation=(self), payment=()' },
        ],
      },
      {
        source: '/api/lists/:listId/qr',
        headers: [
          { key: 'Content-Security-Policy', value: "default-src 'none'; style-src 'unsafe-inline'" },
        ],
      },
    ]
  },

  webpack(config, { isServer }) {
    if (!isServer) {
      config.resolve.fallback = {
        ...config.resolve.fallback,
        fs: false, crypto: false, net: false, tls: false,
      }
    }
    return config
  },
}

module.exports = nextConfig
