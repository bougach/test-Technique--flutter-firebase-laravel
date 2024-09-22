<?php

namespace App\Http\Controllers;

use App\Models\Task;
use Illuminate\Http\Request;

class TaskController extends Controller
{
    public function index() {
        return auth()->user()->tasks;
    }

    public function store(Request $request){
        $request->validate([
            'title' => 'required',
        ]);

        $task = Task::create([
            'title' => $request->title,
            'completed' => $request->completed ?? false,
            'user_id' => auth()->id(),
        ]);

        return response()->json($task, 201);
    }

    public function show($id)
    {
        $task = auth()->user()->tasks()->find($id);

        if ($task) {
            return response()->json($task);
        }

        return response()->json(['message' => 'Task not found'], 404);
    }

    public function update(Request $request, $id)
    {
        $task = auth()->user()->tasks()->find($id);

        if ($task) {
            $task->update($request->all());
            return response()->json($task);
        }

        return response()->json(['message' => 'Task not found'], 404);
    }

    public function destroy($id)
    {
        $task = auth()->user()->tasks()->find($id);

        if ($task) {
            $task->delete();
            return response()->json(['message' => 'Task deleted successfully']);
        }

        return response()->json(['message' => 'Task not found'], 404);
    }

    public function toggleCompleted($id)
{
    $task = Task::find($id);

    if ($task) {
        $task->completed = !$task->completed;
        $task->save();

        return response()->json($task);
    }

    return response()->json(['message' => 'Task not found'], 404);
}
}
