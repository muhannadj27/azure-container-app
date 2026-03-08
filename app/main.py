from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional
import uuid

app = FastAPI(
    title="My To-Do API",
    description="A simple REST API for managing tasks, deployed on Azure Container Apps",
    version="1.0.0"
)

# In-memory storage (resets when container restarts)
tasks = {}


class TaskCreate(BaseModel):
    title: str
    description: Optional[str] = ""


class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    completed: Optional[bool] = None


# Health check endpoint
@app.get("/")
def root():
    return {"message": "Welcome to the To-Do API!", "status": "running"}


# Get all tasks
@app.get("/tasks")
def get_tasks():
    return {"tasks": list(tasks.values()), "count": len(tasks)}


# Get a single task
@app.get("/tasks/{task_id}")
def get_task(task_id: str):
    if task_id not in tasks:
        raise HTTPException(status_code=404, detail="Task not found")
    return tasks[task_id]


# Create a new task
@app.post("/tasks", status_code=201)
def create_task(task: TaskCreate):
    task_id = str(uuid.uuid4())[:8]
    new_task = {
        "id": task_id,
        "title": task.title,
        "description": task.description,
        "completed": False
    }
    tasks[task_id] = new_task
    return new_task


# Update a task
@app.put("/tasks/{task_id}")
def update_task(task_id: str, task: TaskUpdate):
    if task_id not in tasks:
        raise HTTPException(status_code=404, detail="Task not found")
    
    existing = tasks[task_id]
    if task.title is not None:
        existing["title"] = task.title
    if task.description is not None:
        existing["description"] = task.description
    if task.completed is not None:
        existing["completed"] = task.completed
    
    return existing


# Delete a task
@app.delete("/tasks/{task_id}")
def delete_task(task_id: str):
    if task_id not in tasks:
        raise HTTPException(status_code=404, detail="Task not found")
    deleted = tasks.pop(task_id)
    return {"message": "Task deleted", "task": deleted}
