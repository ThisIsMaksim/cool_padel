export class AuthUser {
  userId!: string;
  publicId!: string;
  email!: string;
  name!: string;
}

export interface AuthResponse {
  accessToken: string;
  user: {
    id: string;
    name: string;
    email: string;
    rating: number;
    level: string;
    club: string;
    city: string;
    tournamentHistory: string[];
  };
}
