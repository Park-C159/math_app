DROP DATABASE IF EXISTS math;

CREATE DATABASE math;

USE math;

DROP TABLE IF EXISTS course_question;
DROP TABLE IF EXISTS course_user;
DROP TABLE IF EXISTS exams_question;
DROP TABLE IF EXISTS user_answer;
DROP TABLE IF EXISTS exams;
DROP TABLE IF EXISTS course;

CREATE TABLE course
(
    id         INT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(255) NOT NULL,                                           -- 课程名称
    teacher    VARCHAR(100) NOT NULL,                                           -- 任课老师
    start_time DATE,                                                            -- 开始时间
    end_time   DATE,                                                            --  结束时间
    intro      TEXT,                                                            -- 课程介绍
    period VARCHAR (32),                                                        -- 计划学时
    credit     INT,                                                             -- 学分
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,                             -- 课程创建时间
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- 课程更新时间
    cookies    TEXT,                                                            -- 外部字段
    INDEX idx_name (name)
);

INSERT INTO course (name, teacher, start_time, end_time, intro, cookies)
VALUES ('数理逻辑', '王拥军', '2024-09-01', '2024-12-12',
        '本课程分为数理逻辑与集合论两部分，数理逻辑部分的核心在于用数学的方法研究逻辑，集合论部分的关键在于正确认识无限。',
        'sessionId=abc123; userId=xyz456');

-- INSERT INTO course (name, teacher, start_time, end_time, intro, period, credit, cookies) VALUES
-- ('高等数学', '张老师', '2024-03-01', '2024-06-30', '本课程旨在培养学生的数学思维和解决实际问题的能力。', '64', 4, '无'),
-- ('计算机科学导论', '李教授', '2024-09-01', '2024-12-31', '介绍计算机科学的基本概念和原理。', '48', 3, '无'),
-- ('英语', '王老师', '2024-03-01', '2024-06-30', '提高学生的英语听说读写能力。', '64', 2, '无'),
-- ('物理', '赵博士', '2024-09-01', '2024-12-31', '探索物理世界的基本原理。', '48', 3, '无'),
-- ('化学', '钱老师', '2024-03-01', '2024-06-30', '化学是研究物质的组成、结构、性质和变化规律的科学。', '64', 4, '无');


CREATE TABLE exams
(
    id           INT PRIMARY KEY AUTO_INCREMENT,
    name         VARCHAR(32) NOT NULL,
    course_id    INT,                                 -- 考试所属课程，外键
    start_time   DATETIME,                            -- 考试开始时间
    end_time     DATETIME,                            -- 考试截止时间
    is_checked   BOOLEAN,                             -- 是否批改完成
    is_submitted BOOLEAN   DEFAULT FALSE,             -- 是否已经提交
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 考试发布时间

    FOREIGN KEY (course_id) REFERENCES course (id) ON DELETE CASCADE
);
-- 插入第一次考试记录
INSERT INTO exams (name, course_id, start_time, end_time, is_checked)
VALUES ('期中考试', (SELECT id FROM course WHERE name = '数理逻辑'), '2024-10-15 09:00:00', '2024-10-15 11:00:00',
        FALSE);
-- 插入第二次考试记录
INSERT INTO exams (name, course_id, start_time, end_time, is_checked)
VALUES ('期末考试', (SELECT id FROM course WHERE name = '数理逻辑'), '2024-11-21 09:00:00', '2024-12-01 11:00:00',
        TRUE);

DROP TABLE IF EXISTS question_option;
DROP TABLE IF EXISTS question_flow;
DROP TABLE IF EXISTS question;
CREATE TABLE question
(
    id             INT AUTO_INCREMENT PRIMARY KEY,
    type           ENUM ('choice', 'blank', 'proof', 'flow') NOT NULL, -- 题目类型
    question_text  TEXT                                      NOT NULL, -- 题干内容
    score          FLOAT,
    correct_answer TEXT,                                               -- 正确答案（选择题的正确选项、填空题的正确答案）
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP                 -- 创建时间
);
CREATE TABLE question_option
(
    id           INT AUTO_INCREMENT PRIMARY KEY,
    question_id  INT     NOT NULL,                                       -- 对应的题目ID
    option_label CHAR(1) NOT NULL,                                       -- 选项标识（如 'A', 'B', 'C', 'D'）
    option_text  TEXT    NOT NULL,                                       -- 选项内容
    FOREIGN KEY (question_id) REFERENCES question (id) ON DELETE CASCADE -- 外键，删除题目时级联删除选项
);

CREATE TABLE question_flow
(
    id          INT AUTO_INCREMENT PRIMARY KEY,
    question_id INT    NOT NULL,                                         -- 对应的题目ID
    step_label  BIGINT NOT NULL,                                         -- 选项标识（如 'A', 'B', 'C', 'D'）
    step_text   TEXT   NOT NULL,                                         -- 选项内容
    is_hidden   BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (question_id) REFERENCES question (id) ON DELETE CASCADE -- 外键，删除题目时级联删除选项
);
-- 插入选择题
INSERT INTO question (type, question_text, score, correct_answer)
VALUES ('choice', '以下哪个选项是正确的？', 5, 'A');

-- 获取刚才插入的选择题的 ID（假设 ID 为 1）
-- 插入选择题选项
INSERT INTO question_option (question_id, option_label, option_text)
VALUES (1, 'A', '选项A: 正确'),
       (1, 'B', '选项B: 错误'),
       (1, 'C', '选项C: 错误'),
       (1, 'D', '选项D: 错误');

-- 插入填空题
INSERT INTO question (type, question_text, score, correct_answer)
VALUES ('blank', '___ 是地球的唯一卫星', 5, '月亮');

-- 插入证明题
INSERT INTO question (type, question_text, score, correct_answer)
VALUES ('proof', '若两个数的和为偶数，则它们的积也是偶数', 10,
        "['http://localhost:5000/api/uploads/20241121225952_dang.png','http://localhost:5000/api/uploads/20241121225952_dang.png']");

-- 插入流程题
INSERT INTO question (type, question_text, score, correct_answer)
VALUES ('flow', '从家到公司，以下哪一项是正确的交通流程？', 7, "['', '第二步：下车', '']");

-- 获取刚才插入的流程题的 ID（假设 ID 为 4）
-- 插入流程题的步骤
INSERT INTO question_flow (question_id, step_label, step_text, is_hidden)
VALUES (4, 1, '第一步：乘车', FALSE),
       (4, 2, '第二步：下车', TRUE),
       (4, 3, '第三步：进入办公室', FALSE);

CREATE TABLE exams_question
(
    exam_id     INT NOT NULL,
    question_id INT NOT NULL,
    FOREIGN KEY (question_id) REFERENCES question (id) ON DELETE CASCADE, -- 外键，删除题目时级联删除选项
    FOREIGN KEY (exam_id) REFERENCES exams (id) ON DELETE CASCADE         -- 外键，删除题目时级联删除选项
);
-- 将题目插入到考试中
INSERT INTO exams_question (exam_id, question_id)
VALUES (2, 3),
       (2, 4);

DROP TABLE IF EXISTS users;

CREATE TABLE users
(
    id           INT AUTO_INCREMENT PRIMARY KEY,
    username     VARCHAR(50)                          NOT NULL UNIQUE,
    password     VARCHAR(255)                         NOT NULL,
    user_id      VARCHAR(50),
    phone_number VARCHAR(15),
    role         ENUM ('admin', 'teacher', 'student') NOT NULL,
    gender       TINYINT,
    extra        TEXT
);

INSERT INTO users (username, password, user_id, phone_number, role, extra)
VALUES ('admin_user', 'Admin@123', 'A0001', '12345678901', 'admin', ''),
       ('teacher_user', 'hashed_password_2', 'T0001', '23456789012', 'teacher', ''),
       ('student_user', 'hashed_password_3', 'SY00000000', '34567890123', 'student', ''),
       ('student1', 'password123', '2021001', '13800001001', 'student', NULL),
       ('student2', 'password123', '2021002', '13800001002', 'student', NULL),
       ('student3', 'password123', '2021003', '13800001003', 'student', NULL),
       ('student4', 'password123', '2021004', '13800001004', 'student', NULL),
       ('student5', 'password123', '2021005', '13800001005', 'student', NULL),
       ('student6', 'password123', '2021006', '13800001006', 'student', NULL),
       ('student7', 'password123', '2021007', '13800001007', 'student', NULL),
       ('student8', 'password123', '2021008', '13800001008', 'student', NULL),
       ('student9', 'password123', '2021009', '13800001009', 'student', NULL),
       ('student10', 'password123', '2021010', '13800001010', 'student', NULL),
       ('student11', 'password123', '2021011', '13800001011', 'student', NULL),
       ('student12', 'password123', '2021012', '13800001012', 'student', NULL),
       ('student13', 'password123', '2021013', '13800001013', 'student', NULL),
       ('student14', 'password123', '2021014', '13800001014', 'student', NULL),
       ('student15', 'password123', '2021015', '13800001015', 'student', NULL),
       ('student16', 'password123', '2021016', '13800001016', 'student', NULL),
       ('student17', 'password123', '2021017', '13800001017', 'student', NULL),
       ('student18', 'password123', '2021018', '13800001018', 'student', NULL),
       ('student19', 'password123', '2021019', '13800001019', 'student', NULL),
       ('student20', 'password123', '2021020', '13800001020', 'student', NULL);

-- 创建 user_answer 表，设置 user_id 和 question_id 为联合主键
CREATE TABLE user_answer
(
    user_id     INT  NOT NULL,                       -- 用户ID
    question_id INT  NOT NULL,                       -- 题目ID
    user_answer TEXT NOT NULL,                       -- 用户的答案
    is_correct  BOOLEAN   DEFAULT (NULL),            -- 答案是否正确
    score       INT       DEFAULT -1,
    answered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 做题时间
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES question (id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, question_id)               -- 设置 user_id 和 question_id 为联合主键
);

-- 插入数据
INSERT INTO user_answer (user_id, question_id, user_answer, is_correct)
VALUES (2, 1, 'A', TRUE),     -- 用户1回答题目1，答案正确
       (2, 2, '月球', FALSE), -- 用户2回答题目1，答案错误
       (3, 1, 'D', NULL); -- 用户3回答题目1，答案未评判


CREATE TABLE course_user
(
    course_id int NOT NULL,
    user_id   INT NOT NULL,
    FOREIGN KEY (course_id) REFERENCES course (id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE, -- 外键
    PRIMARY KEY (user_id, course_id)
);

INSERT INTO course_user (course_id, user_id)
VALUES (1, 1),
       (1, 2),
       (1, 3);

DROP TABLE IF EXISTS course_content;

CREATE TABLE course_content
(
    id            INT PRIMARY KEY AUTO_INCREMENT,
    course_name   VARCHAR(255) NOT NULL,
    chapter_title VARCHAR(255) NOT NULL, -- 章节标题
    section_title VARCHAR(255),          -- 小节标题（如果有）
    planned_hours INT DEFAULT 0,         -- 计划学时
    content       TEXT,                  -- 学习内容描述
    video_link    VARCHAR(255)           -- 相关视频链接
);

INSERT INTO course_content (chapter_title, course_name, section_title, planned_hours, content, video_link)
VALUES
-- 第一章 绪论
('第一章 绪论', '数理逻辑', NULL, 2,
 '- 漫谈数理逻辑的缘起、发展和前沿研究动向；\n - 现代数学大厦的基础--集合论；\n - 课程的两个关键目标：推理和无限；\n - 与其他学科领域的关系，主要是代数和计算机科学。',
 NULL),

-- 第二章 命题演算
('第二章 命题演算', '数理逻辑', '一、非形式的命题演算', 12,
 '- 命题和逻辑连接词 \n体会命题语言，理解其中逻辑连接词带来的逻辑表达能力。\n- 真值函数与真值表\n逻辑连接词的含义，命题形式的含义。\n - 操作与替换规则\n代换与替换，逻辑等价和逻辑蕴含，对偶式，关于逻辑连接词的数学归纳\n- 析取范式与合取范式\n析取范式意味着只含逻辑连接词“非”、“与”、“或”的命题形式具有完备的逻辑表达能力。使用对偶方式获得合取范式。\n- 连接词完备集\n逻辑连接词的极小完备集合，主要关注三种情况。\n- 论证有效性\n使用逻辑连接词“若则”的真值函数定义理解论证有效性。证明重言式和有效论证之间的关系。',
 NULL),
('第二章 命题演算', '数理逻辑', '二、形式的命题演算', 12,
 '形式系统L\n三条公理模式，一条推演规则（分离规则）。严谨定义“证明”概念，继而在假设集合下给出“逻辑结果”定义。\n元定理是刻画形式系统整体性质的定理，包含演绎定理、可靠性定理和完备性定理。',
 NULL),

-- 第三章 谓词演算
('第三章 谓词演算', '数理逻辑', '一、非形式的谓词演算', 14,
 '谓词逻辑除了具有命题逻辑的推理能力之外，还研究量的关系之间的推理能力（比如一般到特殊）。通过引入谓词和量词的概念，拓展逻辑表达能力。',
 NULL),
('第三章 谓词演算', '数理逻辑', '二、形式的谓词演算', 14,
 '形式系统K\n六条公理模式和两条推演规则，严格定义了谓词逻辑中的推理规则和形式。', NULL),
('第三章 谓词演算', '数理逻辑', '三、模型理论', 14,
 '通过形式系统的解释进一步给出模型的概念，并讨论系统的一致性与模型存在的关系。', NULL),

-- 第四章 数学系统
('第四章 数学系统', '数理逻辑', NULL, 4,
 '逻辑公理意味着普遍有效，而数学公理意味着具体研究领域内关于“真”的选择。数学系统是指逻辑公理和数学公理共同充当推理出发点的形式系统。',
 NULL),
('第四章 数学系统', '数理逻辑', '一、从谓词演算到数学系统', 4,
 '讨论逻辑有效和数学真，给出带等词（三条数学公理）的数学系统。', NULL),
('第四章 数学系统', '数理逻辑', '二、数学系统示例1：形式群理论', 4, '在引入等词的数学系统基础上，再加入三条群公理。', NULL),
('第四章 数学系统', '数理逻辑', '三、数学系统示例2：形式算术理论', 4, '在引入等词的数学系统基础上，再加入七条算术公理。',
 NULL),
-- 第五章 哥德尔不完全性定理
('第五章 哥德尔不完全性定理', '数理逻辑', NULL, 0,
 '哥德尔不完全性定理背景介绍；\n从罗素悖论到对角线论证；\n哥德尔提出的三项原创证明技术；\n不完全性证明的主要思路。', NULL),

-- 第六章 集合与类
('第六章 集合与类', '数理逻辑', NULL, 8, '集合是现代数学大厦的基础概念。包括朴素集合论和ZF公理系统，讨论序数与无限公理。',
 NULL),

-- 第七章 替换公理与基础公理
('第七章 替换公理与基础公理', '数理逻辑', NULL, 4,
 'ZF公理体系的两个剩余公理：替换公理与基础公理。涉及无限集合、大集合、序数算术等内容。', NULL),

-- 第八章 选择公理和基数
('第八章 选择公理和基数', '数理逻辑', NULL, 4,
 '基数的概念，体现集合的元素个数。选择公理几乎存在于所有现有数学中，等价于任何集合可良序。', NULL);


-- CREATE TABLE IF EXISTS course_question;

CREATE TABLE course_question
(
    course_id   INT NOT NULL,
    question_id INT NOT NULL,
    FOREIGN KEY (question_id) REFERENCES question (id) ON DELETE CASCADE,    -- 外键，删除题目时级联删除选项
    FOREIGN KEY (course_id) REFERENCES course_content (id) ON DELETE CASCADE -- 外键，删除题目时级联删除选项
);

INSERT INTO course_question (course_id, question_id)
VALUES (1, 1),
       (1, 2);



DROP TABLE IF EXISTS options;
DROP TABLE IF EXISTS flows;
DROP TABLE IF EXISTS user_answers;
DROP TABLE IF EXISTS questions;

CREATE TABLE questions
(
    id             INT AUTO_INCREMENT PRIMARY KEY,
    course_id      INT                                       NOT NULL, -- 所属课程的ID
    question_type  ENUM ('choice', 'blank', 'proof', 'flow') NOT NULL, -- 题目类型
    question_text  TEXT                                      NOT NULL, -- 题干内容
    correct_answer TEXT                                      NOT NULL, -- 正确答案（选择题的正确选项、填空题的正确答案）
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,                -- 创建时间
    INDEX (course_id)                                                  -- 通过课程和小节确定题目所属位置
);


CREATE TABLE options
(
    id           INT AUTO_INCREMENT PRIMARY KEY,
    question_id  INT     NOT NULL,                                        -- 对应的题目ID
    option_label CHAR(1) NOT NULL,                                        -- 选项标识（如 'A', 'B', 'C', 'D'）
    option_text  TEXT    NOT NULL,                                        -- 选项内容
    FOREIGN KEY (question_id) REFERENCES questions (id) ON DELETE CASCADE -- 外键，删除题目时级联删除选项
);

CREATE TABLE flows
(
    id          INT AUTO_INCREMENT PRIMARY KEY,
    question_id INT    NOT NULL,                                          -- 对应的题目ID
    step_label  BIGINT NOT NULL,                                          -- 选项标识（如 'A', 'B', 'C', 'D'）
    step_text   TEXT   NOT NULL,                                          -- 选项内容
    is_hidden   BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (question_id) REFERENCES questions (id) ON DELETE CASCADE -- 外键，删除题目时级联删除选项
);

-- 插入选择题
INSERT INTO questions (course_id, question_type, question_text, correct_answer)
VALUES (5, 'choice', '以下关于数理逻辑的描述，哪一项是正确的？', 'C');

-- 插入选择题的选项
INSERT INTO options (question_id, option_label, option_text)
VALUES (1, 'A', '数理逻辑的核心目标是理解物理现象的因果关系'),
       (1, 'B', '数理逻辑的两个关键目标是推理和集合论'),
       (1, 'C', '数理逻辑的两个关键目标是推理和无限'),
       (1, 'D', '数理逻辑只与计算机科学有密切关系');
-- 插入填空题
INSERT INTO questions (course_id, question_type, question_text, correct_answer)
VALUES (5, 'blank', '数理逻辑的发展与______密切相关，除了代数，它还与______密切联系。', '集合论,计算机科学');
-- 插入流程题
INSERT INTO questions (course_id, question_type, question_text, correct_answer)
VALUES (5, 'flow', '请按照以下步骤完成命题逻辑推理。已知命题 A 和命题 B，依据逻辑关系推导出最终的结论。', '2, 4');

-- 2. 获取刚插入流程题的 ID
SET @question_id = 3;

-- 插入流程步骤到 flows 表
INSERT INTO flows (question_id, step_label, step_text, is_hidden)
VALUES (@question_id, 1, '假设命题 A 为真', FALSE),
       (@question_id, 2, '若命题 A 为真，则命题 B 为真', TRUE),
       (@question_id, 3, '假设命题 B 为真，则可以推出命题 C 为真', FALSE),
       (@question_id, 4, '若命题 C 为真，则推导出命题 D 为真', TRUE),
       (@question_id, 5, '根据命题 D 为真，可以得出最终结论：命题 E 为真', FALSE);



DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS discussions;
DROP TABLE IF EXISTS user_like_comment;

-- 创建 discussions 表
CREATE TABLE discussions
(
    id               INT AUTO_INCREMENT PRIMARY KEY,
    course_id        INT  NOT NULL,
    author_id        INT  NOT NULL,
    `like`           INT       DEFAULT 0,
    content          TEXT NOT NULL,
    teacher_involved BOOLEAN   DEFAULT FALSE,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (course_id) REFERENCES course (id),
    FOREIGN KEY (author_id) REFERENCES users (id),

    INDEX idx_course_id (course_id),
    INDEX idx_author_id (author_id),
    INDEX idx_teacher_involved (teacher_involved)
);

INSERT INTO discussions (course_id, author_id, content)
VALUES (1, (SELECT id FROM users WHERE username = 'student1'), '这门课程的内容很有趣，希望能学到很多知识。'),
       (1, (SELECT id FROM users WHERE username = 'student2'), '老师讲课非常清晰，对知识点的解释很透彻。'),
       (1, (SELECT id FROM users WHERE username = 'student3'), '课程作业有点难度，但是很有挑战性。'),
       (1, (SELECT id FROM users WHERE username = 'student4'), '希望能有更多的实践机会，理论知识太多了。'),
       (1, (SELECT id FROM users WHERE username = 'student5'), '对这门课程的内容很感兴趣，期待学习更多。'),
       (1, (SELECT id FROM users WHERE username = 'student6'), '课程进度有点快，需要花很多时间消化知识。'),
       (1, (SELECT id FROM users WHERE username = 'student7'), '学习资料很丰富，对理解课程内容很有帮助。'),
       (1, (SELECT id FROM users WHERE username = 'student8'), '老师很有耐心，对学生的问题都能给出详细解答。'),
       (1, (SELECT id FROM users WHERE username = 'student9'), '小组作业让我们能够互相学习，很有收获。'),
       (1, (SELECT id FROM users WHERE username = 'student10'), '希望能有更多的课堂互动和讨论。'),
       (1, (SELECT id FROM users WHERE username = 'student11'), '课程内容很有深度，对专业知识的理解帮助很大。'),
       (1, (SELECT id FROM users WHERE username = 'student12'), '课堂氛围很好，大家都很积极参与。'),
       (1, (SELECT id FROM users WHERE username = 'student13'), '对这门课程的一些概念还不太理解，需要再深入学习。'),
       (1, (SELECT id FROM users WHERE username = 'student14'), '老师的教学方法很独特，让学习变得有趣。'),
       (1, (SELECT id FROM users WHERE username = 'student15'), '希望能有更多的实验课和实践机会。'),
       (1, (SELECT id FROM users WHERE username = 'student16'), '课程资源很丰富，对自学很有帮助。'),
       (1, (SELECT id FROM users WHERE username = 'student17'), '对课程内容的深度和广度都很满意。'),
       (1, (SELECT id FROM users WHERE username = 'student18'), '老师很注重培养学生的批判性思维。'),
       (1, (SELECT id FROM users WHERE username = 'student19'), '课程作业设计很有创意，能让我们多思考。'),
       (1, (SELECT id FROM users WHERE username = 'student20'), '希望能有更多的跨学科视角和案例分析。'),
       (1, (SELECT id FROM users WHERE username = 'student1'), '第二次发言：对课程的理解越来越深入了。'),
       (1, (SELECT id FROM users WHERE username = 'student2'), '再次感谢老师的耐心指导。'),
       (1, (SELECT id FROM users WHERE username = 'student3'), '课程的理论基础很扎实。'),
       (1, (SELECT id FROM users WHERE username = 'student4'), '对课程内容有了更多的思考和感悟。'),
       (1, (SELECT id FROM users WHERE username = 'student5'), '越来越喜欢这门课程了。'),
       (1, (SELECT id FROM users WHERE username = 'student6'), '学习过程很充实，收获很多。'),
       (1, (SELECT id FROM users WHERE username = 'student7'), '对专业知识有了更深入的理解。'),
       (1, (SELECT id FROM users WHERE username = 'student8'), '课程给了我很大的启发。'),
       (1, (SELECT id FROM users WHERE username = 'student9'), '期待未来能继续学习相关内容。'),
       (1, (SELECT id FROM users WHERE username = 'student10'), '对课程的要求和期望有了更清晰的认识。');

CREATE TABLE replies
(
    id            INT AUTO_INCREMENT PRIMARY KEY,
    parent_id     INT                          NOT NULL,
    replier_id    INT                          NOT NULL,
    target_type   ENUM ('discussion', 'reply') NOT NULL,
    target_id     INT,
    `like`        INT       DEFAULT 0,
    reply_content TEXT                         NOT NULL,
    reply_time    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (parent_id) REFERENCES discussions (id) ON DELETE CASCADE,
    FOREIGN KEY (replier_id) REFERENCES users (id),

    INDEX idx_discussion_id (parent_id),
    INDEX idx_replier_id (replier_id),
    INDEX idx_target_id (target_type)
);

INSERT INTO replies (parent_id, replier_id, target_type, target_id, reply_content)
VALUES
-- 第1条讨论的回复
(1, (SELECT id FROM users WHERE username = 'student2'), 'discussion', 1, '非常赞同你的观点，学习心得很有价值'),
(1, (SELECT id FROM users WHERE username = 'student3'), 'reply', 1, '对学习方法很感兴趣，可以分享更多细节吗？'),

-- 第2条讨论的回复
(2, (SELECT id FROM users WHERE username = 'student5'), 'discussion', 2, '我也有同样的疑问，希望老师能解答'),
(2, (SELECT id FROM users WHERE username = 'student7'), 'reply', 3, '建议可以查阅一下课程参考资料'),

-- 第3条讨论的回复
(3, (SELECT id FROM users WHERE username = 'student1'), 'discussion', 3, '确实，这门课程很有意思！'),
(3, (SELECT id FROM users WHERE username = 'student4'), 'reply', 5, '我也学到了很多新知识');

CREATE TABLE user_like_comment
(
    id         INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT                          NOT NULL,
    dor        ENUM ('discussion', 'reply') NOT NULL,
    comment_id INT                          NOT NULL,

    UNIQUE KEY unique_like (user_id, dor, comment_id),
    FOREIGN KEY (user_id) REFERENCES users (id),
    INDEX idx_user_id (user_id),
    INDEX idx_dor_comment_id (dor, comment_id)
);

CREATE TABLE user_answers
(
    id          INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT     NOT NULL,                    -- 用户ID
    question_id INT     NOT NULL,                    -- 题目ID
    user_answer TEXT    NOT NULL,                    -- 用户的答案
    is_correct  BOOLEAN NOT NULL,                    -- 答案是否正确
    answered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 做题时间
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions (id) ON DELETE CASCADE,
    INDEX (user_id),                                 -- 为用户ID建立索引
    INDEX (question_id)                              -- 为题目ID建立索引
);


INSERT INTO user_answers (user_id, question_id, user_answer, is_correct)
VALUES (1, 1, 'A', TRUE),        -- 用户1回答题目1，答案正确
       (1, 2, 'C', FALSE),       -- 用户1回答题目2，答案错误
       (2, 1, 'B', FALSE),       -- 用户2回答题目1，答案错误
       (2, 3, '填空答案', TRUE), -- 用户2回答题目3，答案正确
       (3, 2, '选择答案', TRUE); -- 用户3回答题目2，答案正确


DROP TABLE IF EXISTS links;
DROP TABLE IF EXISTS nodes;
DROP TABLE IF EXISTS categories;

CREATE TABLE IF NOT EXISTS categories (
    id INT PRIMARY KEY,
    name VARCHAR(255)
);
CREATE TABLE IF NOT EXISTS nodes (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    value INT,
    category INT,
    FOREIGN KEY (category) REFERENCES categories(id)  -- 外键关联到 categories 表
);
CREATE TABLE IF NOT EXISTS links (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    source INT,
    target INT,
    FOREIGN KEY (source) REFERENCES nodes(id),
    FOREIGN KEY (target) REFERENCES nodes(id)
);

DROP TABLE IF EXISTS topics;
CREATE TABLE topics (
    id INT AUTO_INCREMENT PRIMARY KEY,      -- 话题ID，自增主键
    tag VARCHAR(255) NOT NULL,              -- 话题标题
    content TEXT,                           -- 话题内容
    pdf_url VARCHAR(500)                    -- PDF文件URL
);

DROP TABLE IF EXISTS topic_comment;
CREATE TABLE topic_comment (
    id INT AUTO_INCREMENT PRIMARY KEY,      -- 评论ID，自增主键
    topic_id INT NOT NULL,                  -- 关联的话题ID，与 topics.id 保持一致
    user VARCHAR(100) NOT NULL,             -- 用户名
    content TEXT NOT NULL,                  -- 评论内容
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 创建时间，默认为当前时间
    FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE
);

INSERT INTO topics (id, tag, content, pdf_url) VALUES
(1, '数理逻辑与集合论', '关于数理逻辑与集合论的详细内容介绍。', 'https://cdn.jsdelivr.net/gh/themusecatcher/resources@0.0.3/Markdown.pdf'),
(2, '哈密尔顿回路有关问题讨论', '对哈密尔顿回路问题进行深入研究与讨论。', 'https://zuopengd.github.io/vue-pdf3/dist/欢迎使用WPS Office for Mac同步文件夹.pdf'),
(3, '标签3', '这是关于标签3的内容描述。', NULL);

INSERT INTO topic_comment (id, topic_id, user, content, created_at) VALUES
(1, 1, '李四', '内容讲解得非常详细，受益匪浅。', '2024-12-15 12:23:43'),
(2, 1, '孙七', '这篇内容与我的研究方向非常相关，非常感谢！', '2024-12-17 12:23:43'),
(3, 2, '李四', '内容讲解得非常详细，受益匪浅。', '2024-12-10 12:23:43'),
(4, 2, '孙七', '内容讲解得非常详细，受益匪浅。', '2024-12-18 12:23:43'),
(5, 2, '赵六', '我认为这一部分可以再补充一些实例。', '2024-12-13 12:23:43'),
(6, 3, '赵六', '内容讲解得非常详细，受益匪浅。', '2024-12-21 12:23:43'),
(7, 3, '王五', '我认为这一部分可以再补充一些实例。', '2024-12-16 12:23:43');



DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS sessions;

CREATE TABLE IF NOT EXISTS sessions (
    session_id CHAR(36) PRIMARY KEY,  -- 使用UUID作为会话ID
    user_id INT,                      -- 外键关联到用户表
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS messages (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    session_id CHAR(36),  -- 外键关联到会话表
    user_id INT,          -- 外键关联到用户表
    message TEXT NOT NULL,
    message_type ENUM('user', 'assistant') NOT NULL,  -- 消息类别：用户消息或生成结果
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,   -- 消息的时间戳
    FOREIGN KEY (session_id) REFERENCES sessions(session_id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

