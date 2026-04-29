import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateCommentDto } from './dto/create-comment.dto';
import { CreatePostDto } from './dto/create-post.dto';

@Injectable()
export class PostsService {
  constructor(private readonly prisma: PrismaService) {}

  async createPost(userId: string, dto: CreatePostDto, imageUrl: string) {
    const post = await this.prisma.post.create({
      data: {
        authorId: userId,
        imageUrl,
        caption: dto.caption?.trim() || null,
      },
      include: this.postIncludes(userId),
    });

    return { post: this.toPostResponse(post, userId) };
  }

  async getFeed(userId: string) {
    const posts = await this.prisma.post.findMany({
      orderBy: { createdAt: 'desc' },
      include: this.postIncludes(userId),
    });

    return { posts: posts.map((post) => this.toPostResponse(post, userId)) };
  }

  async getPost(userId: string, postId: string) {
    const post = await this.prisma.post.findUnique({
      where: { id: postId },
      include: this.postIncludes(userId),
    });

    if (!post) {
      throw new NotFoundException('Post was not found.');
    }

    return { post: this.toPostResponse(post, userId) };
  }

  async deletePost(userId: string, postId: string) {
    const post = await this.prisma.post.findUnique({ where: { id: postId } });

    if (!post) {
      throw new NotFoundException('Post was not found.');
    }

    if (post.authorId !== userId) {
      throw new ForbiddenException('Only the post owner can delete this post.');
    }

    await this.prisma.post.delete({ where: { id: postId } });
    return { message: 'Post deleted.' };
  }

  async likePost(userId: string, postId: string) {
    await this.ensurePostExists(postId);

    await this.prisma.like.upsert({
      where: { userId_postId: { userId, postId } },
      update: {},
      create: { userId, postId },
    });

    return this.getPost(userId, postId);
  }

  async unlikePost(userId: string, postId: string) {
    await this.ensurePostExists(postId);

    await this.prisma.like.deleteMany({
      where: { userId, postId },
    });

    return this.getPost(userId, postId);
  }

  async getComments(postId: string) {
    await this.ensurePostExists(postId);

    const comments = await this.prisma.comment.findMany({
      where: { postId },
      orderBy: { createdAt: 'asc' },
      include: { user: true },
    });

    return { comments: comments.map((comment) => this.toCommentResponse(comment)) };
  }

  async createComment(userId: string, postId: string, dto: CreateCommentDto) {
    await this.ensurePostExists(postId);

    const comment = await this.prisma.comment.create({
      data: {
        postId,
        userId,
        text: dto.text.trim(),
      },
      include: { user: true },
    });

    return { comment: this.toCommentResponse(comment) };
  }

  async deleteComment(userId: string, commentId: string) {
    const comment = await this.prisma.comment.findUnique({
      where: { id: commentId },
    });

    if (!comment) {
      throw new NotFoundException('Comment was not found.');
    }

    if (comment.userId !== userId) {
      throw new ForbiddenException('Only the comment owner can delete this comment.');
    }

    await this.prisma.comment.delete({ where: { id: commentId } });
    return { message: 'Comment deleted.' };
  }

  private async ensurePostExists(postId: string) {
    const post = await this.prisma.post.findUnique({ where: { id: postId } });
    if (!post) {
      throw new NotFoundException('Post was not found.');
    }
  }

  private postIncludes(userId: string) {
    return {
      author: true,
      likes: { where: { userId } },
      _count: { select: { likes: true, comments: true } },
    } as const;
  }

  private toPostResponse(post: {
    id: string;
    imageUrl: string;
    caption: string | null;
    createdAt: Date;
    author: { id: string; name: string | null; email: string; photoUrl: string | null };
    likes: { id: string }[];
    _count: { likes: number; comments: number };
  }, userId: string) {
    return {
      id: post.id,
      imageUrl: post.imageUrl,
      caption: post.caption,
      createdAt: post.createdAt.toISOString(),
      author: {
        id: post.author.id,
        name: post.author.name,
        email: post.author.email,
        photoUrl: post.author.photoUrl,
      },
      likeCount: post._count.likes,
      commentCount: post._count.comments,
      likedByMe: post.likes.some(Boolean),
      ownedByMe: post.author.id === userId,
    };
  }

  private toCommentResponse(comment: {
    id: string;
    text: string;
    createdAt: Date;
    user: { id: string; name: string | null; email: string; photoUrl: string | null };
  }) {
    return {
      id: comment.id,
      text: comment.text,
      createdAt: comment.createdAt.toISOString(),
      user: {
        id: comment.user.id,
        name: comment.user.name,
        email: comment.user.email,
        photoUrl: comment.user.photoUrl,
      },
    };
  }
}
