# TwoDo

**Life management for couples** - A shared "OS for two people"

TwoDo is a couples-focused life-management app that helps two people run their shared life together. It combines shared tasks, calendars, routines, and gentle reminders into a calm, collaborative interface.

## Features

- **Shared Tasks**: Create and assign tasks to either partner or both
- **Shared Calendar**: Track important dates, appointments, and events
- **Routines & Habits**: Define recurring routines that generate tasks automatically
- **Gentle Reminders**: Get notified about time-sensitive items
- **Today View**: See what matters today in a single, calm dashboard
- **Real-time Sync**: Changes made by your partner appear instantly

## Tech Stack

### Backend
- **Runtime**: Node.js 20+
- **Framework**: Fastify 4.x
- **Database**: PostgreSQL 16+
- **ORM**: Drizzle ORM
- **Cache/Queue**: Redis 7+ with BullMQ
- **Language**: TypeScript 5.x

### Frontend
- **Web**: React 18 + Vite + TailwindCSS
- **Mobile**: React Native (Expo) - Coming soon
- **State**: TanStack Query + Zustand
- **Language**: TypeScript 5.x

### Infrastructure
- **Monorepo**: pnpm workspaces + Turborepo
- **Containerization**: Docker + Docker Compose
- **CI/CD**: GitHub Actions

## Getting Started

### Prerequisites

- Node.js 20 or higher
- pnpm 8 or higher
- Docker and Docker Compose (for local development)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-org/twodo.git
cd twodo
```

2. Install dependencies:
```bash
pnpm install
```

3. Set up environment variables:
```bash
cp .env.example .env
cp apps/api/.env.example apps/api/.env
cp apps/web/.env.example apps/web/.env
```

4. Start the database and Redis:
```bash
docker-compose up -d
```

5. Run database migrations:
```bash
pnpm db:migrate
```

6. Start the development servers:
```bash
pnpm dev
```

This will start:
- **API**: http://localhost:3000
- **Web**: http://localhost:5173

### Project Structure

```
twodo/
├── apps/
│   ├── api/              # Backend API (Fastify)
│   ├── web/              # Web frontend (React)
│   └── mobile/           # Mobile app (React Native) - Coming soon
├── packages/
│   ├── shared/           # Shared types and schemas
│   ├── database/         # Database schemas and migrations
│   └── ui/               # Shared UI components - Coming soon
├── .github/
│   └── workflows/        # CI/CD pipelines
├── docker-compose.yml    # Local development services
└── package.json          # Root package.json
```

## Development

### Available Scripts

- `pnpm dev` - Start all development servers
- `pnpm build` - Build all packages
- `pnpm test` - Run tests across all packages
- `pnpm lint` - Lint all packages
- `pnpm clean` - Clean all build artifacts

### Database Commands

- `pnpm db:migrate` - Run database migrations
- `pnpm db:seed` - Seed database with test data
- `pnpm --filter database studio` - Open Drizzle Studio

## Deployment

Deployment instructions will be added as the project progresses through Phase 0-7 of development.

## Contributing

This project is currently in early development. Contribution guidelines will be added soon.

## License

[License TBD]

## Roadmap

### Phase 0: Foundation ✅ (In Progress)
- [x] Monorepo setup
- [x] Development environment
- [x] Database schema
- [x] Backend API scaffold
- [x] Web app scaffold
- [x] CI/CD pipeline
- [ ] Authentication system

### Phase 1: Core Task Management (Next)
- [ ] Couple creation and invitation
- [ ] Task lists and tasks
- [ ] Task assignment and completion
- [ ] Basic UI

### Phase 2-7: See full specification for details

---

Built with ❤️ for couples who want to navigate life together.
