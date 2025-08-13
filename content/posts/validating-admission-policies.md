+++
title = "Validating Admission Policies for Kubernetes"
description = "A Primer for using Validating Admission Policies in Kubernetes"
date = 2024-03-03
author = {name = "Curtis Goolsby", email = "cvioling@gmail.com"}
tags = ["kubernetes", "admission-control", "security"]
+++

## [Validating Admission Policies](https://kubernetes.io/blog/2022/12/20/validating-admission-policies-alpha/)
### Common Expression Language (CEL)

The **Common Expression Language (CEL)** is a powerful and flexible language designed for evaluating expressions, particularly in environments where policy rules, configuration validation, or resource processing are required. It is lightweight, JSON-oriented, and allows users to write concise and readable expressions to evaluate resource attributes and policies.

#### Key Features of CEL:
1. **Type-Safe and High-Level**:
   CEL is type-safe, ensuring correct usage of types (e.g., strings, integers, booleans, lists, maps). It also provides high-level operations on these types, enabling users to write robust expressions.

2. **JSON/Nested Data Support**:
   CEL is built for evaluating structured data like JSON or protocol buffers, making it ideal for Kubernetes resources, typically defined in YAML or JSON.

3. **Simplified Syntax**:
   CEL's syntax is straightforward and expressive, resembling expressions in high-level languages like Python or JavaScript:
   - Logical operations: `&&`, `||`, `!`
   - Comparison: `<`, `<=`, `==`, `!=`, `>`, `>=`
   - Membership: `in` or `!in`

4. **Stateless Execution**:
   CEL expressions are stateless, meaning their evaluation does not depend on external state changes. This ensures consistency and predictability.

5. **Customizable and Extensible**:
   CEL can be extended with custom functions, allowing organizations to tailor it for specific use cases or domain-specific operations.

#### Why Kubernetes Uses CEL:
Kubernetes integrates CEL for its **ValidatingAdmissionPolicies** to provide administrators with a flexible way to enforce constraints and policies on resource configurations. CEL makes it easy to:
- Validate resource fields dynamically based on complex conditions.
- Create fine-grained admission policies without writing custom webhooks.
- Improve maintainability by replacing custom code with declarative, reusable expressions.

#### Examples of CEL Expressions not found in the kubernetes documentation
- Ensure a label exists on a resource:
    ```cel
      "environment" in object.metadata.labels
    ```
- Validate that a container's image uses a specific tag:
    ```cel
      object.spec.containers.all(c, c.image.endsWith(":latest"))
    ```
- Validate that a resource's name matches a specific pattern:
    ```cel
      object.metadata.name.matches("^project-[0-9]+$")
    ```
- Validate that a pod's memory request is within a specific range:
    ```cel
      object.spec.containers.all(c, c.resources.requests.memory >= "1Gi" && c.resources.requests.memory <= "4Gi")
    ```


### Write Tests First!
When writing Validating Admission Policies, it's best to write tests first to ensure that the policy behaves as expected. This approach helps you define the desired behavior upfront and ensures that the policy meets your requirements.

### Full example and test suite
```yml
apiVersion: admissionregistration.k8s.io/v1beta1 # change for 1.30
kind: ValidatingAdmissionPolicy
metadata:
  name: template-policy
spec:
  failurePolicy: Fail
  matchConstraints:
    resourceRules:
    - apiGroups: [""]
      apiVersions: ["v1"]
      operations: ["CREATE", "UPDATE"]
      resources: ["pods"]

  validations:
  # If an expression evaluates to false, the validation check is enforced according to the spec.failurePolicy field.
    - expression: "object.spec.containers.all(c, !('securityContext' in c) || c.securityContext.runAsUser == 20876 || c.securityContext.runAsUser == 1000)"
      message: "if runAsUser is set, runAsUser must be one of [20876, 1000]"
    - expression: "object.spec.volumes.all(v, !('hostPath' in v) || (v.hostPath.path.startsWith('/allowed/prefix1') || v.hostPath.path.startsWith('/allowed/prefix2')))"
      message: "hostPath volumes must start with one of [/allowed/prefix1, /allowed/prefix2]"
---
apiVersion: admissionregistration.k8s.io/v1beta1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: template-policy-binding
spec:
  policyName: template-policy
  validationActions: [Deny]
  matchResources:
    namespaceSelector:
      matchLabels:
        project: template 
```

```yml
apiVersion: v1
kind: Namespace
metadata:
  name: template-test
  labels:
    project: template
---
### 
# Passing pods
###
# Pod with No securityContext
---
apiVersion: v1
kind: Pod
metadata:
  name: SHOULDPASS-no-securitycontext
  namespace: template-test
spec:
  containers:
  - name: test
    image: busybox
    command: ["sleep", "3600"]

---
# Pod with securityContext.runAsUser set to 20876
---
apiVersion: v1
kind: Pod
metadata:
  name: SHOULDPASS-runasuser-20876
  namespace: template-test
spec:
  containers:
  - name: test
    image: busybox
    securityContext:
      runAsUser: 20876
    command: ["sleep", "3600"]

---
# Pod with securityContext.runAsUser set to 1000
---
apiVersion: v1
kind: Pod
metadata:
  name: SHOULDPASS-runasuser-1000
  namespace: template-test
spec:
  containers:
  - name: test
    image: busybox
    securityContext:
      runAsUser: 1000
    command: ["sleep", "3600"]

---
# Pod with securityContext.runAsUser set to 1000 and 20876
---
apiVersion: v1
kind: Pod
metadata:
  name: SHOULDPASS-multiple-runasuser
  namespace: template-test
spec:
  containers:
  - name: test1
    image: busybox
    securityContext:
      runAsUser: 1000
    command: ["sleep", "3600"]
  - name: test2
    image: busybox
    securityContext:
      runAsUser: 20876
    command: ["sleep", "3600"]

---
# container with a correct securityContext and a container with a correct hostPath
---
apiVersion: v1
kind: Pod
metadata:
  name: SHOULDPASS-correct-securitycontext-hostpath
  namespace: template-test
spec:
  containers:
  - name: test1
    image: busybox
    securityContext:
      runAsUser: 20876
    command: ["sleep", "3600"]
  - name: test2
    image: busybox
    volumeMounts:
    - name: allowed-volume
      mountPath: /mnt
  volumes:
  - name: allowed-volume
    hostPath:
      path: /allowed/prefix1

---
# container with a correct hostPath
---
apiVersion: v1
kind: Pod
metadata:
  name: SHOULDPASS-correct-hostpath
  namespace: template-test
spec:
  containers:
  - name: test
    image: busybox
    volumeMounts:
    - name: allowed-volume
      mountPath: /mnt
  volumes:
  - name: allowed-volume
    hostPath:
      path: /allowed/prefix1

### 
# Failing pods
###
# container with securityContext.runAsUser set to 1000 and container with an incorrect securityContext
---
apiVersion: v1
kind: Pod
metadata:
  name: DONOTPASS-mixed-correct-and-incorrect-securitycontext
  namespace: template-test
spec:
  containers:
  - name: test1
    image: busybox
    securityContext:
      runAsUser: 1000
    command: ["sleep", "3600"]
  - name: test2
    image: busybox
    securityContext:
      runAsUser: 9999
    command: ["sleep", "3600"]

---
# container with a correct hostPath and a container with an incorrect hostPath
---
apiVersion: v1
kind: Pod
metadata:
  name: DONOTPASS-mixed-correct-and-incorrect-hostpath
  namespace: template-test
spec:
  containers:
  - name: test1
    image: busybox
    volumeMounts:
    - name: allowed-volume
      mountPath: /mnt
  - name: test2
    image: busybox
    volumeMounts:
    - name: disallowed-volume
      mountPath: /mnt2
  volumes:
  - name: allowed-volume
    hostPath:
      path: /allowed/prefix1
  - name: disallowed-volume
    hostPath:
      path: /disallowed/path

---
# container with a correct securityContext and a container with an incorrect hostPath
---
apiVersion: v1
kind: Pod
metadata:
  name: DONOTPASS-correct-securitycontext-incorrect-hostpath
  namespace: template-test
spec:
  containers:
  - name: test1
    image: busybox
    securityContext:
      runAsUser: 20876
    volumeMounts:
    - name: disallowed-volume
      mountPath: /mnt2
  volumes:
  - name: disallowed-volume
    hostPath:
      path: /disallowed/path
```


###  Bonus VAP Example to prevent privilege escalation
If a user is only allowed to get/watch/create deployments, but not list secrets in a namespace. This will prevent the user from
1. Mounting a secret into a pod
2. Using -oyaml to get the secret

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicy
metadata:
  name: "refcheck-core-pods"
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        operations: ["CREATE", "UPDATE"]
        resources: ["pods"]
  validations:
    - expression: |
        !has(object.spec) || 'has(object.spec.containers) ||
        object.spec.containers.all(c, !has(c.envFrom) || c.envFrom.all(eF, !has(eF.secretRef) || !has(eF.secretRef.name) ||
        authorizer.group("").resource("secrets").namespace(namespaceObject.metadata.name).name(eF.secretRef.name).check("get").allowed()))
```
