# 课程教学

这是一个综合性的代数课程体系学习系统，它集成了课程学习、资料共享、在线测试等多种功能。用户可以通过它访问丰富的教育资源，进行自主学习，同时支持教师发布课程内容和作业，便于远程教学。此外，本还提供了互动讨论区，促进师生间的沟通交流，是现代教育技术应用的一个便捷工具。
并且提供了一些基本工具帮助老师和学生更好的熟悉课程内容，并且根据数学学科特点，提供公式编辑器、习题生成器等功能。

## Recommended IDE Setup

[VSCode](https://code.visualstudio.com/) + [Volar](https://marketplace.visualstudio.com/items?itemName=Vue.volar) (and disable Vetur).

## 技术栈

前端采用vue3+element-ui搭建平台，由于部分组件不兼容问题，还有部分内容采用了vue2的部分兼容模式。

后端采用python的flask框架。

部署计划采用docker+nginx简化部署流程。

数据库采用mysql数据库用来存放基本信息。

## 运行程序

```sh
npm install
```

### Compile and Hot-Reload for Development

```sh
npm run dev
```

### Type-Check, Compile and Minify for Production

```sh
npm run build
```

## 数据库表说明

### 1. `course_content` 表
存储课程内容的相关信息。

| 列名             | 数据类型          | 描述             |
| ---------------- | ----------------- | ---------------- |
| `id`             | INT               | 主键，自增 ID     |
| `course_name`    | VARCHAR(255)      | 课程名称         |
| `chapter_title`  | VARCHAR(255)      | 章节标题         |
| `section_title`  | VARCHAR(255)      | 小节标题（可为空）|
| `planned_hours`  | INT               | 计划学时         |
| `content`        | TEXT              | 学习内容描述     |
| `video_link`     | VARCHAR(255)      | 相关视频链接     |

### 2. `question` 表
该表用于存储所有的题目信息，包括选择题、填空题、证明题、流程题等不同类型的题目。

| 列名              | 数据类型                          | 描述                                       |
| ----------------- | --------------------------------- | ------------------------------------------ |
| `id`              | INT                               | 主键，自增 ID                               |
| `type`            | ENUM('choice','blank','proof','flow') | 题目类型（选择题、填空题、证明题、流程题） |
| `question_text`   | TEXT                              | 题目内容                                   |
| `score`           | FLOAT                             | 题目分数                                   |
| `correct_answer`  | TEXT                              | 正确答案                                   |
| `created_at`      | TIMESTAMP                         | 创建时间，默认为当前时间                   |

### 3. `options` 表
存储选择题的选项内容，与 `questions` 表建立外键关联。

| 列名             | 数据类型          | 描述                       |
| ---------------- | ----------------- | -------------------------- |
| `id`             | INT               | 主键，自增 ID               |
| `question_id`    | INT               | 关联的题目 ID               |
| `option_label`   | CHAR(1)           | 选项标识（如 'A', 'B'）     |
| `option_text`    | TEXT              | 选项内容                   |

### 4. `flows` 表
存储流程题的步骤内容，与 `questions` 表建立外键关联。

| 列名             | 数据类型          | 描述                       |
| ---------------- | ----------------- | -------------------------- |
| `id`             | INT               | 主键，自增 ID               |
| `question_id`    | INT               | 关联的题目 ID               |
| `step_label`     | BIGINT            | 步骤标签（如 '1', '2'）      |
| `step_text`      | TEXT              | 步骤内容                   |
| `is_hidden`      | BOOLEAN           | 是否隐藏步骤，默认 FALSE    |

### 5. `discussions` 表
存储课程讨论内容。

| 列名             | 数据类型          | 描述                     |
| ---------------- | ----------------- | ------------------------ |
| `id`             | INT               | 主键，自增 ID             |
| `course_name`    | VARCHAR(255)      | 课程名称                 |
| `author`         | VARCHAR(255)      | 发布者                   |
| `content`        | TEXT              | 讨论内容                 |
| `score`          | BIGINT            | 分数                    |
| `created_at`     | TIMESTAMP         | 创建时间，默认当前时间   |
| `updated_at`     | TIMESTAMP         | 更新时间                 |

### 6. `replies` 表
存储对讨论内容的回复，与 `discussions` 表建立外键关联。

| 列名             | 数据类型          | 描述                     |
| ---------------- | ----------------- | ------------------------ |
| `id`             | INT               | 主键，自增 ID             |
| `discussion_id`  | INT               | 关联的讨论 ID             |
| `replier`        | VARCHAR(255)      | 回复者                   |
| `reply_content`  | TEXT              | 回复内容                 |
| `reply_time`     | TIMESTAMP         | 回复时间，默认当前时间   |

### 7. `users` 表
存储用户信息，包括用户名、密码、角色等信息。

| 列名             | 数据类型          | 描述                     |
| ---------------- | ----------------- | ------------------------ |
| `id`             | INT               | 主键，自增 ID             |
| `username`       | VARCHAR(50)       | 用户名                   |
| `password`       | VARCHAR(255)      | 密码（已加密）           |
| `user_id`        | VARCHAR(50)       | 用户 ID                  |
| `phone_number`   | VARCHAR(15)       | 电话号码（可为空）       |
| `role`           | ENUM('admin', 'teacher', 'student') | 用户角色 |
| `extra`          | TEXT              | 额外信息                 |

### 8. `course_question` 表
该表用于存储课程与题目的关系，即每个课程可以有多个题目，关联 `course_id` 和 `question_id`。

| 列名           | 数据类型   | 描述                       |
| -------------- | ---------- | -------------------------- |
| `course_id`    | INT        | 关联的课程 ID               |
| `question_id`  | INT        | 关联的题目 ID               |

---

## 接口说明

1. /api/course - 获取课程结构

**描述**: 根据课程名称返回课程的章节和小节结构。  
**方法**: `GET`  
**响应**:返回课程结构的树状 JSON 对象 **示例**:
```json
[
  {
    "id": 1,
    "label": "第一章 绪论",
    "time": 2,
    "children": [
      {
        "label": "小节 1",
        "id": 2,
        "time": 1,
        "children": []
      }
    ]
  }
]
```

## 设计思路

1. 需要一个主界面
2. 可扩展的课程编辑器
3. 习题编辑器
4. 公式编辑器功能
5. 考试出题能力（primary）
6. 用户分级策略
7. 习题书写可视化，下载
8. 分级课程分数汇总