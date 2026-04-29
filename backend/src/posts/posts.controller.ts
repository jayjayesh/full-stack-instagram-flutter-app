import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Req,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { Request } from 'express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { CurrentUser, JwtUser } from '../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CreateCommentDto } from './dto/create-comment.dto';
import { CreatePostDto } from './dto/create-post.dto';
import { PostsService } from './posts.service';

const imageStorage = diskStorage({
  destination: './uploads',
  filename: (_req, file, callback) => {
    const uniqueName = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
    callback(null, `${uniqueName}${extname(file.originalname)}`);
  },
});

@UseGuards(JwtAuthGuard)
@Controller()
export class PostsController {
  constructor(private readonly postsService: PostsService) {}

  @Post('posts')
  @UseInterceptors(
    FileInterceptor('photo', {
      storage: imageStorage,
      limits: { fileSize: 5 * 1024 * 1024 },
      fileFilter: (_req, file, callback) => {
        if (!file.mimetype.startsWith('image/')) {
          callback(new BadRequestException('Only image uploads are allowed.'), false);
          return;
        }
        callback(null, true);
      },
    }),
  )
  createPost(
    @CurrentUser() user: JwtUser,
    @Body() dto: CreatePostDto,
    @UploadedFile() file: Express.Multer.File | undefined,
    @Req() request: Request,
  ) {
    if (!file) {
      throw new BadRequestException('Please choose a photo before posting.');
    }

    const imageUrl = `${request.protocol}://${request.get('host')}/uploads/${file.filename}`;
    return this.postsService.createPost(user.id, dto, imageUrl);
  }

  @Get('posts/feed')
  getFeed(@CurrentUser() user: JwtUser) {
    return this.postsService.getFeed(user.id);
  }

  @Get('posts/:id')
  getPost(@CurrentUser() user: JwtUser, @Param('id') postId: string) {
    return this.postsService.getPost(user.id, postId);
  }

  @Delete('posts/:id')
  deletePost(@CurrentUser() user: JwtUser, @Param('id') postId: string) {
    return this.postsService.deletePost(user.id, postId);
  }

  @Post('posts/:id/like')
  likePost(@CurrentUser() user: JwtUser, @Param('id') postId: string) {
    return this.postsService.likePost(user.id, postId);
  }

  @Delete('posts/:id/like')
  unlikePost(@CurrentUser() user: JwtUser, @Param('id') postId: string) {
    return this.postsService.unlikePost(user.id, postId);
  }

  @Get('posts/:id/comments')
  getComments(@Param('id') postId: string) {
    return this.postsService.getComments(postId);
  }

  @Post('posts/:id/comments')
  createComment(
    @CurrentUser() user: JwtUser,
    @Param('id') postId: string,
    @Body() dto: CreateCommentDto,
  ) {
    return this.postsService.createComment(user.id, postId, dto);
  }

  @Delete('comments/:id')
  deleteComment(@CurrentUser() user: JwtUser, @Param('id') commentId: string) {
    return this.postsService.deleteComment(user.id, commentId);
  }
}
