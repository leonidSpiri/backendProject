import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:data/models/author.dart';
import 'package:data/models/post.dart';
import 'package:data/utils/app_utils.dart';

import '../utils/app_response.dart';

class AppPostController extends ResourceController {
  final ManagedContext managedContext;

  AppPostController(this.managedContext);

  @Operation.get()
  Future<Response> getPosts(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
  ) async {
    try {
      final authorId = AppUtils.getIdFromHeader(header);
      final queryGetPosts = Query<Post>(managedContext)
        ..where((post) => post.author?.id).equalTo(authorId);
      final List<Post> authorPosts = await queryGetPosts.fetch();
      if (authorPosts.isEmpty) {
        return AppResponse.notFound(
            error: "Not Found", message: "Posts not found");
      }
      return Response.ok(authorPosts);
    } catch (error) {
      return AppResponse.serverError(error, message: "get Posts failed");
    }
  }

  @Operation.get("id")
  Future<Response> getPost(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path("id") int id) async {
    try {
      final authorId = AppUtils.getIdFromHeader(header);
      final post = await managedContext.fetchObjectWithID<Post>(id);

      if (post == null)
        return AppResponse.notFound(
            error: "Not Found", message: "Post not found");

      if (post.author?.id != authorId)
        return AppResponse.unauthorized(
            error: "Unauthorized",
            message: "No permission to access this post");

      post.backing.removeProperty("author");

      return AppResponse.ok(
          body: post.backing.contents, message: "get Post success");
    } catch (error) {
      return AppResponse.serverError(error, message: "get Post failed");
    }
  }

  @Operation.post()
  Future<Response> createPost(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.body() Post post,
  ) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final author = await managedContext.fetchObjectWithID<Author>(id);
      if (author == null) {
        final qCreateAuthor = Query<Author>(managedContext)..values.id = id;
        await qCreateAuthor.insert();
      }

      final qCreatePost = Query<Post>(managedContext)
        ..values.title = post.title
        ..values.body = post.body
        ..values.author?.id = id;
      final createdPost = await qCreatePost.insert();
      createdPost.backing.removeProperty("author");
      return AppResponse.ok(
          body: createdPost.backing.contents, message: "Create Post success");
    } catch (error) {
      return AppResponse.serverError(error, message: "Create Post failed");
    }
  }

  @Operation.delete("id")
  Future<Response> deletePost(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path("id") int id) async {
    try {
      final authorId = AppUtils.getIdFromHeader(header);
      final post = await managedContext.fetchObjectWithID<Post>(id);

      if (post == null)
        return AppResponse.notFound(
            error: "Not Found", message: "Post not found");

      if (post.author?.id != authorId)
        return AppResponse.unauthorized(
            error: "Unauthorized",
            message: "No permission to access this post");

      final queryDeletePost = Query<Post>(managedContext)
        ..where((p) => p.id).equalTo(id);
      await queryDeletePost.delete();
      return AppResponse.ok(message: "delete Post success");
    } catch (error) {
      return AppResponse.serverError(error, message: "delete Post failed");
    }
  }
}
