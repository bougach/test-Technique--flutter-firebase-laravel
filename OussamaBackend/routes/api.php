<?php

use App\Http\Controllers\TaskController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
//     return $request->user();
// });

Route::middleware(['auth.firebase'])->group(function(){
    Route::get('/tasks', [TaskController::class, 'index']);        
    Route::post('/tasks', [TaskController::class, 'store']);       
    Route::get('/tasks/{id}', [TaskController::class, 'show']);    
    Route::put('/tasks/{id}', [TaskController::class, 'update']);  
    Route::patch('/tasks/{id}/toggle', [TaskController::class, 'toggleCompleted']);
    Route::delete('/tasks/{id}', [TaskController::class, 'destroy']);
});