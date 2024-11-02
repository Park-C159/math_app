DROP TABLE IF EXISTS course_content;

CREATE TABLE course_content (
    id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(255) NOT NULL,
    chapter_title VARCHAR(255) NOT NULL,       -- 章节标题
    section_title VARCHAR(255),                -- 小节标题（如果有）
    planned_hours INT DEFAULT 0,                -- 计划学时
    content TEXT,                     -- 学习内容描述
    video_link VARCHAR(255)                    -- 相关视频链接
);
INSERT INTO course_content(chapter_title, section_title, course_name)
VALUES('数理逻辑', '期末考试', '考试'),('数理逻辑', '期中考试', '考试'),('可计算', '期中考试', '考试'),('可计算', '期末考试', '考试');

INSERT INTO course_content (chapter_title, course_name, section_title, planned_hours, content, video_link)
VALUES
-- 第一章 绪论
('第一章 绪论', '数理逻辑', NULL, 2, '- 漫谈数理逻辑的缘起、发展和前沿研究动向；\n - 现代数学大厦的基础--集合论；\n - 课程的两个关键目标：推理和无限；\n - 与其他学科领域的关系，主要是代数和计算机科学。', NULL),

-- 第二章 命题演算
('第二章 命题演算', '数理逻辑', '一、非形式的命题演算', 12, '- 命题和逻辑连接词 \n体会命题语言，理解其中逻辑连接词带来的逻辑表达能力。\n- 真值函数与真值表\n逻辑连接词的含义，命题形式的含义。\n - 操作与替换规则\n代换与替换，逻辑等价和逻辑蕴含，对偶式，关于逻辑连接词的数学归纳\n- 析取范式与合取范式\n析取范式意味着只含逻辑连接词“非”、“与”、“或”的命题形式具有完备的逻辑表达能力。使用对偶方式获得合取范式。\n- 连接词完备集\n逻辑连接词的极小完备集合，主要关注三种情况。\n- 论证有效性\n使用逻辑连接词“若则”的真值函数定义理解论证有效性。证明重言式和有效论证之间的关系。', NULL),
('第二章 命题演算', '数理逻辑', '二、形式的命题演算', 12, '形式系统L\n三条公理模式，一条推演规则（分离规则）。严谨定义“证明”概念，继而在假设集合下给出“逻辑结果”定义。\n元定理是刻画形式系统整体性质的定理，包含演绎定理、可靠性定理和完备性定理。', NULL),

-- 第三章 谓词演算
('第三章 谓词演算', '数理逻辑', '一、非形式的谓词演算', 14, '谓词逻辑除了具有命题逻辑的推理能力之外，还研究量的关系之间的推理能力（比如一般到特殊）。通过引入谓词和量词的概念，拓展逻辑表达能力。', NULL),
('第三章 谓词演算', '数理逻辑', '二、形式的谓词演算', 14, '形式系统K\n六条公理模式和两条推演规则，严格定义了谓词逻辑中的推理规则和形式。', NULL),
('第三章 谓词演算', '数理逻辑', '三、模型理论', 14, '通过形式系统的解释进一步给出模型的概念，并讨论系统的一致性与模型存在的关系。', NULL),

-- 第四章 数学系统
('第四章 数学系统', '数理逻辑', NULL, 4, '逻辑公理意味着普遍有效，而数学公理意味着具体研究领域内关于“真”的选择。数学系统是指逻辑公理和数学公理共同充当推理出发点的形式系统。', NULL),
('第四章 数学系统', '数理逻辑', '一、从谓词演算到数学系统', 4, '讨论逻辑有效和数学真，给出带等词（三条数学公理）的数学系统。', NULL),
('第四章 数学系统', '数理逻辑', '二、数学系统示例1：形式群理论', 4, '在引入等词的数学系统基础上，再加入三条群公理。', NULL),
('第四章 数学系统', '数理逻辑', '三、数学系统示例2：形式算术理论', 4, '在引入等词的数学系统基础上，再加入七条算术公理。', NULL),
-- 第五章 哥德尔不完全性定理
('第五章 哥德尔不完全性定理', '数理逻辑', NULL, 0, '哥德尔不完全性定理背景介绍；\n从罗素悖论到对角线论证；\n哥德尔提出的三项原创证明技术；\n不完全性证明的主要思路。', NULL),

-- 第六章 集合与类
('第六章 集合与类', '数理逻辑', NULL, 8, '集合是现代数学大厦的基础概念。包括朴素集合论和ZF公理系统，讨论序数与无限公理。', NULL),

-- 第七章 替换公理与基础公理
('第七章 替换公理与基础公理', '数理逻辑', NULL, 4, 'ZF公理体系的两个剩余公理：替换公理与基础公理。涉及无限集合、大集合、序数算术等内容。', NULL),

-- 第八章 选择公理和基数
('第八章 选择公理和基数', '数理逻辑', NULL, 4, '基数的概念，体现集合的元素个数。选择公理几乎存在于所有现有数学中，等价于任何集合可良序。', NULL);

DROP TABLE IF EXISTS options;
DROP TABLE IF EXISTS flows;

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,           -- 所属课程的ID
    question_type ENUM('choice', 'blank', 'proof', 'flow') NOT NULL,  -- 题目类型
    question_text TEXT NOT NULL,      -- 题干内容
    correct_answer TEXT NOT NULL,     -- 正确答案（选择题的正确选项、填空题的正确答案）
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- 创建时间
    INDEX (course_id)     -- 通过课程和小节确定题目所属位置
);


CREATE TABLE options (
    id INT AUTO_INCREMENT PRIMARY KEY,
    question_id INT NOT NULL,         -- 对应的题目ID
    option_label CHAR(1) NOT NULL,    -- 选项标识（如 'A', 'B', 'C', 'D'）
    option_text TEXT NOT NULL,        -- 选项内容
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE  -- 外键，删除题目时级联删除选项
);

CREATE TABLE flows (
    id INT AUTO_INCREMENT PRIMARY KEY,
    question_id INT NOT NULL,         -- 对应的题目ID
    step_label BIGINT NOT NULL,    -- 选项标识（如 'A', 'B', 'C', 'D'）
    step_text TEXT NOT NULL,        -- 选项内容
    is_hidden BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE  -- 外键，删除题目时级联删除选项
);

-- 插入选择题
INSERT INTO questions (course_id, question_type, question_text, correct_answer)
VALUES
(1,  'choice', '以下关于数理逻辑的描述，哪一项是正确的？', 'C');

-- 插入选择题的选项
INSERT INTO options (question_id, option_label, option_text)
VALUES
(1, 'A', '数理逻辑的核心目标是理解物理现象的因果关系'),
(1, 'B', '数理逻辑的两个关键目标是推理和集合论'),
(1, 'C', '数理逻辑的两个关键目标是推理和无限'),
(1, 'D', '数理逻辑只与计算机科学有密切关系');
-- 插入填空题
INSERT INTO questions (course_id, question_type, question_text, correct_answer)
VALUES
(1,  'blank', '数理逻辑的发展与______密切相关，除了代数，它还与______密切联系。', '集合论,计算机科学');
-- 插入流程题
INSERT INTO questions (course_id, question_type, question_text, correct_answer)
VALUES (1, 'flow', '请按照以下步骤完成命题逻辑推理。已知命题 A 和命题 B，依据逻辑关系推导出最终的结论。', '2, 4');

-- 2. 获取刚插入流程题的 ID
SET @question_id = 3;

-- 插入流程步骤到 flows 表
INSERT INTO flows (question_id, step_label, step_text, is_hidden)
VALUES
    (@question_id, 1, '假设命题 A 为真', FALSE),
    (@question_id, 2, '若命题 A 为真，则命题 B 为真', TRUE),
    (@question_id, 3, '假设命题 B 为真，则可以推出命题 C 为真', FALSE),
    (@question_id, 4, '若命题 C 为真，则推导出命题 D 为真', TRUE),
    (@question_id, 5, '根据命题 D 为真，可以得出最终结论：命题 E 为真', FALSE);



DROP TABLE IF EXISTS replies;

DROP TABLE IF EXISTS discussions;
-- 创建 discussions 表
CREATE TABLE discussions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,       -- 发布者
    content TEXT NOT NULL,              -- 讨论内容
    score BIGINT, -- 的分数
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- 发布时间
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP  -- 更新时间
);

-- 创建 replies 表
CREATE TABLE replies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    discussion_id INT NOT NULL,         -- 关联的讨论ID
    replier VARCHAR(255) NOT NULL,      -- 回复者
    score BIGINT, -- 的分数
    reply_content TEXT NOT NULL,        -- 回复内容
    reply_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- 回复时间
    FOREIGN KEY (discussion_id) REFERENCES discussions(id) ON DELETE CASCADE  -- 外键，删除讨论时级联删除回复
);

-- 插入 20 条讨论
INSERT INTO discussions (course_name, author, content) VALUES
('数理逻辑', '张三', '数理逻辑的基本定义与应用是什么？'),
('数理逻辑', '李四', '请问在数理逻辑中如何证明一个命题的真实性？'),
('数理逻辑', '王五', '数理逻辑的推理能力有多强？'),
('数理逻辑', '赵六', '数理逻辑与集合论的关系是什么？'),
('数理逻辑', '孙七', '请解释数理逻辑的基本原理。'),
('数理逻辑', '周八', '在数理逻辑中，公理系统的意义是什么？'),
('数理逻辑', '吴九', '数理逻辑在计算机科学中的应用有哪些？'),
('数理逻辑', '郑十', '数理逻辑的发展历史是怎样的？'),
('数理逻辑', '黄一', '数理逻辑中常用的推理规则有哪些？'),
('数理逻辑', '刘二', '在数理逻辑中，如何构建一个有效的推理系统？'),
('数理逻辑', '陈三', '数理逻辑中的归纳法和演绎法有什么区别？'),
('数理逻辑', '章四', '如何在数理逻辑中进行公理化系统的构建？'),
('数理逻辑', '赵五', '数理逻辑中的范式转换是如何进行的？'),
('数理逻辑', '钱六', '数理逻辑在哲学中的作用是什么？'),
('数理逻辑', '孙七', '数理逻辑的核心概念有哪些？'),
('数理逻辑', '李八', '数理逻辑中的逻辑演算是如何实现的？'),
('数理逻辑', '吴九', '数理逻辑的完备性和一致性如何定义？'),
('数理逻辑', '陈十', '数理逻辑在数学中的重要性是什么？'),
('数理逻辑', '郑十一', '数理逻辑的模型理论是如何发展的？'),
('数理逻辑', '黄十二', '数理逻辑中的谓词逻辑和命题逻辑有何不同？');

-- 为每条讨论插入 5 条回复
INSERT INTO replies (discussion_id, replier, reply_content) VALUES
(3, '李四', '数理逻辑可以用来推理复杂的逻辑关系。'),
(3, '张三', '我认为数理逻辑的推理能力是非常强的。'),
(3, '王五', '数理逻辑是推理数学问题的基础。'),
(3, '孙七', '数理逻辑在计算机科学中的作用不可忽视。'),
(3, '赵六', '数理逻辑可以帮助理解集合论的基本概念。'),

(4, '李四', '数理逻辑和集合论都是数学的基础理论。'),
(4, '张三', '数理逻辑在集合论中有很大的应用。'),
(4, '王五', '数理逻辑是集合论的逻辑基础。'),
(4, '孙七', '在数理逻辑中，集合论是一个重要的研究方向。'),
(4, '赵六', '集合论和数理逻辑是相辅相成的。'),

(5, '李四', '数理逻辑的基本原理包括推理和证明。'),
(5, '张三', '数理逻辑的原理可以用于解释复杂的数学问题。'),
(5, '王五', '数理逻辑在计算机科学中有着重要的应用。'),
(5, '孙七', '数理逻辑是研究逻辑推理的基本工具。'),
(5, '赵六', '数理逻辑帮助理解数学的基本逻辑结构。'),

-- 以下为其余讨论的回复，类似的结构
(6, '李四', '公理系统是数理逻辑的基础。'),
(6, '张三', '数理逻辑中的公理系统是用来证明命题的。'),
(6, '王五', '公理系统是数理逻辑中的重要部分。'),
(6, '孙七', '公理系统在数理逻辑中的地位很高。'),
(6, '赵六', '数理逻辑中的公理系统非常重要。'),

(7, '李四', '数理逻辑在计算机科学中的应用非常广泛。'),
(7, '张三', '数理逻辑是计算机科学的核心内容之一。'),
(7, '王五', '数理逻辑可以用来设计程序。'),
(7, '孙七', '数理逻辑在编程语言中起到重要作用。'),
(7, '赵六', '数理逻辑帮助理解计算机科学的基础概念。');

-- 此处仅插入部分讨论和回复，其他讨论与回复可以以类似方式继续插入
-- 注意：要保证每个 discussion_id 对应正确的讨论
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    user_id VARCHAR(50) NOT NULL,
    phone_number VARCHAR(15),
    role ENUM('admin', 'teacher', 'student') NOT NULL,
    extra TEXT
);

INSERT INTO users (username, password, user_id, phone_number, role, extra) VALUES
('admin_user', 'Admin@123', 'A0001', '12345678901', 'admin', ''),
('teacher_user', 'hashed_password_2', 'T0001', '23456789012', 'teacher', ''),
('student_user', 'hashed_password_3', 'SY00000000', '34567890123', 'student', '');

