import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';

describe('Instagram clone API', () => {
  let app: INestApplication;
  let accessToken: string;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleRef.createNestApplication();
    app.setGlobalPrefix('api');
    app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('signs up or logs in a user', async () => {
    const email = `student-${Date.now()}@example.com`;

    const signup = await request(app.getHttpServer())
      .post('/api/auth/signup')
      .send({ name: 'Student', email, password: 'password123' })
      .expect(201);

    expect(signup.body.accessToken).toBeDefined();
    accessToken = signup.body.accessToken;

    const me = await request(app.getHttpServer())
      .get('/api/auth/me')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200);

    expect(me.body.user.email).toBe(email);
  });

  it('blocks protected routes without a token', async () => {
    await request(app.getHttpServer()).get('/api/posts/feed').expect(401);
  });
});
